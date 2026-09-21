# create-ca-policy1-require-mfa.ps1
# Creates Conditional Access policies in Report-only mode.

param(
    [Parameter(Mandatory)][string]$ExcludeAdminUPN  # admin account excluded from the policy
)

$excludeAdminId = (Get-MgUser -Filter "userPrincipalName eq '$excludeAdminUPN'").Id

if (-not $excludeAdminId) {
    Write-Host "Could not find admin account '$excludeAdminUPN' - check the UPN and try again." -ForegroundColor Red
    return
}

$policies = @(
    @{
        DisplayName = "CA01-Require-MFA-AllUsers"
        IncludeApps = @("MicrosoftAdminPortals")
        BuiltInControls = @("mfa")
    }
)

foreach ($p in $policies) {
    try {
        Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies" -Body @{
            displayName = $p.DisplayName
            state       = "enabledForReportingButNotEnforced"
            conditions  = @{
                users = @{
                    includeUsers = @("All")
                    excludeUsers = @($excludeAdminId)
                }
                applications = @{
                    includeApplications = $p.IncludeApps
                }
            }
            grantControls = @{
                operator        = "OR"
                builtInControls = $p.BuiltInControls
            }
        } -ContentType "application/json"
        Write-Host "Created: $($p.DisplayName)" -ForegroundColor Green
    } catch {
        Write-Host "Failed to create $($p.DisplayName): $_" -ForegroundColor Red
    }
}
