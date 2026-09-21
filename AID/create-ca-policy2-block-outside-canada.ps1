# create-ca-policy2-block-outside-canada.ps1
# Creates a Named Location for Canada (or reuses it if it already exists),
# then a Conditional Access policy that blocks access from outside it.
# Report-only mode.

param(
    [Parameter(Mandatory)][string]$ExcludeAdminUPN  # admin account excluded from the policy
)

$excludeAdminId = (Get-MgUser -Filter "userPrincipalName eq '$excludeAdminUPN'").Id

if (-not $excludeAdminId) {
    Write-Host "Could not find admin account '$excludeAdminUPN' - check the UPN and try again." -ForegroundColor Red
    return
}

try {
    $existingLocation = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/namedLocations").value |
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
        } -ContentType "application/json"

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
    } -ContentType "application/json"
    Write-Host "Created: CA02-Block-OutsideCanada" -ForegroundColor Green
} catch {
    Write-Host "Failed to create CA02-Block-OutsideCanada: $_" -ForegroundColor Red
}