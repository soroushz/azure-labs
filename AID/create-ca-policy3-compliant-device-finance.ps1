# create-ca-policy3-compliant-device-finance.ps1
# Requires a compliant device for the Finance-Team group. Report-only mode.

try {
    if (-not (Get-MgContext)) {
        throw "Not connected to Microsoft Graph. Run .\connect-azure.ps1 first."
    }

    $financeGroupId = (Get-MgGroup -Filter "displayName eq 'Finance-Team'" -ErrorAction Stop).Id
    if (-not $financeGroupId) {
        throw "Could not find group 'Finance-Team' - check the group name and try again."
    }
} catch {
    Write-Host "Failed: $_" -ForegroundColor Red
    return
}

try {
    Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies" -Body @{
        displayName = "CA03-RequireCompliantDevice-FinanceTeam"
        state       = "enabledForReportingButNotEnforced"
        conditions  = @{
            users = @{
                includeGroups = @($financeGroupId)
            }
            applications = @{
                includeApplications = @("All")
            }
        }
        grantControls = @{
            operator        = "OR"
            builtInControls = @("compliantDevice")
        }
    } -ContentType "application/json" -ErrorAction Stop
    Write-Host "Created: CA03-RequireCompliantDevice-FinanceTeam" -ForegroundColor Green
} catch {
    Write-Host "Failed to create CA03-RequireCompliantDevice-FinanceTeam: $_" -ForegroundColor Red
}