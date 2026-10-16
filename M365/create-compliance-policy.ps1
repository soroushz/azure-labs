# create-compliance-policy.ps1
# Creates Intune compliance policies from an array and assigns each to a
# Microsoft Entra security group. Idempotent is NOT guaranteed - re-running
# creates duplicate policies. Assignment uses Invoke-MgGraphRequest to the
# /assign action endpoint directly, bypassing a known SDK routing bug in
# New-MgDeviceManagementDeviceCompliancePolicyAssignment.
# Requires: Microsoft.Graph.DeviceManagement module, DeviceManagementConfiguration.ReadWrite.All
# granted on the calling app registration, and a live Graph session (run connect-azure.ps1 first).

param(
    [string]$GroupName = "IT-Admins"
)

try {
    if (-not (Get-MgContext)) {
        throw "Not connected to Microsoft Graph. Run .\connect-azure.ps1 first."
    }

    $group = Get-MgGroup -Filter "displayName eq '$GroupName'"
    if (-not $group) {
        throw "Group '$GroupName' not found."
    }
    $groupId = $group.Id

    $policies = @(
        @{
            "@odata.type"         = "#microsoft.graph.windows10CompliancePolicy"
            displayName           = "Windows 11 Baseline Compliance"
            description           = "Requires BitLocker, a strong password, and a minimum OS build"
            bitLockerEnabled      = $true
            passwordRequired      = $true
            passwordMinimumLength = 8
            passwordRequiredType  = "alphanumeric"
            osMinimumVersion      = "10.0.22621"
            scheduledActionsForRule = @(
                @{
                    ruleName                      = "PasswordRequired"
                    scheduledActionConfigurations = @(
                        @{
                            actionType       = "block"
                            gracePeriodHours = 72
                        }
                    )
                }
            )
        }
    )

    foreach ($policy in $policies) {
        $newPolicy = New-MgDeviceManagementDeviceCompliancePolicy -BodyParameter $policy -ErrorAction Stop

        $assignmentBody = @{
            assignments = @(
                @{
                    target = @{
                        "@odata.type" = "#microsoft.graph.groupAssignmentTarget"
                        groupId       = $groupId
                    }
                }
            )
        }
        Invoke-MgGraphRequest -Method POST `
            -Uri "https://graph.microsoft.com/v1.0/deviceManagement/deviceCompliancePolicies/$($newPolicy.Id)/assign" `
            -Body ($assignmentBody | ConvertTo-Json -Depth 5) `
            -ErrorAction Stop

        Write-Host "Created and assigned: $($newPolicy.DisplayName) [$($newPolicy.Id)]" -ForegroundColor Green
    }

    Write-Host "Success!" -ForegroundColor Green
} catch {
    Write-Host "Failed: $_" -ForegroundColor Red
}