# create-ca-policy2-block-outside-canada.ps1
# Creates a Named Location for Canada (or reuses it if it already exists),
# then a Conditional Access policy that blocks access from outside it.
# Report-only mode.

param(
    [Parameter(Mandatory)][string]$ExcludeAdminUPN  # admin account excluded from the policy
)

try {
    if (-not (Get-MgContext)) {
        throw "Not connected to Microsoft Graph. Run .\connect-azure.ps1 first."
    }

    $excludeAdminId = (Get-MgUser -Filter "userPrincipalName eq '$ExcludeAdminUPN'" -ErrorAction Stop).Id
    if (-not $excludeAdminId) {
        throw "Could not find admin account '$ExcludeAdminUPN' - check the UPN and try again."
    }
} catch {
    Write-Host "Failed: $_" -ForegroundColor Red
    return
}

try {
    $existingLocation = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/namedLocations" -ErrorAction Stop).value |
        Where-Object { $_.displayName -eq "Canada" }

    if ($existingLocation) {
        $locationId = $existingLocation.id
        Write-Host "Named location 'Canada' already exists (id: $locationId) - reusing it" -ForegroundColor Yellow
    } else {
        $namedLocation = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/namedLocations" -Body @{
            "@odata.type"                     = "#microsoft.graph.countryNamedLocation"
            displayName                       = "Canada"
            countriesAndRegions               = @("CA")
            includeUnknownCountriesAndRegions = $false
        } -ContentType "application/json" -ErrorAction Stop

        $locationId = $namedLocation.id
        Write-Host "Named location created: Canada (id: $locationId)" -ForegroundColor Green

        Write-Host "Waiting 15 seconds for the new location to fully register..." -ForegroundColor Cyan
        Start-Sleep -Seconds 15
    }
} catch {
    Write-Host "Failed to create/find named location: $_" -ForegroundColor Red
    return
}

try {
    Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies" -Body @{
        displayName = "CA02-Block-OutsideCanada"
        state       = "enabledForReportingButNotEnforced"
        conditions  = @{
            users = @{
                includeUsers = @("All")
                excludeUsers = @($excludeAdminId)
            }
            applications = @{
                includeApplications = @("All")
            }
            locations = @{
                includeLocations = @("All")
                excludeLocations = @($locationId)
            }
        }
        grantControls = @{
            operator        = "OR"
            builtInControls = @("block")
        }
    } -ContentType "application/json" -ErrorAction Stop
    Write-Host "Created: CA02-Block-OutsideCanada" -ForegroundColor Green
} catch {
    Write-Host "Failed to create CA02-Block-OutsideCanada: $_" -ForegroundColor Red
}