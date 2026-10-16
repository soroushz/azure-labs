<#
.SYNOPSIS
    Deploys Microsoft 365 Apps through Intune and assigns it to an Entra security group.
.DESCRIPTION
    Builds one or more Intune mobile app entries from an array and assigns each as a
    required install to the target group. Uses Invoke-MgGraphRequest throughout for
    consistency with the compliance and configuration profile scripts, avoiding the
    same class of typed-cmdlet routing issues hit in those.
.NOTES
    Requires an active Microsoft Graph connection (see connect-azure.ps1) with
    DeviceManagementApps.ReadWrite.All permission.
    officeSuiteApp only exists on the Graph beta endpoint, not v1.0 — both calls
    below target beta on purpose.
#>

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

    $apps = @(
        @{
            "@odata.type"                   = "#microsoft.graph.officeSuiteApp"
            displayName                     = "Microsoft 365 Apps for Windows"
            description                     = "Word, Excel, PowerPoint, Outlook, and Teams, auto-deployed to managed devices"
            publisher                       = "Microsoft"
            productIds                      = @("O365ProPlusRetail")
            updateChannel                   = "current"
            officePlatformArchitecture      = "x64"
            autoAcceptEula                  = $true
            officeSuiteAppDefaultFileFormat = "officeOpenXMLFormat"
        }
    )

    foreach ($app in $apps) {
        $newApp = Invoke-MgGraphRequest -Method POST `
            -Uri "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps" `
            -Body ($app | ConvertTo-Json -Depth 5) `
            -ErrorAction Stop

        $assignmentBody = @{
            mobileAppAssignments = @(
                @{
                    "@odata.type" = "#microsoft.graph.mobileAppAssignment"
                    intent        = "required"
                    target        = @{
                        "@odata.type" = "#microsoft.graph.groupAssignmentTarget"
                        groupId       = $groupId
                    }
                }
            )
        }

        Invoke-MgGraphRequest -Method POST `
            -Uri "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps/$($newApp.id)/assign" `
            -Body ($assignmentBody | ConvertTo-Json -Depth 5) `
            -ErrorAction Stop

        Write-Host "Created and assigned: $($newApp.displayName) [$($newApp.id)]" -ForegroundColor Green
    }

    Write-Host "Success!" -ForegroundColor Green
}
catch {
    Write-Host "Failed: $_" -ForegroundColor Red
}