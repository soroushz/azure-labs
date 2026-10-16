<#
.SYNOPSIS
    Creates Intune device configuration profiles and assigns them to an Entra security group.
.DESCRIPTION
    Builds one or more Windows device configuration profiles from an array and assigns
    each to the target group. Uses Invoke-MgGraphRequest for assignment to work around
    a known Microsoft Graph SDK routing bug in the typed assignment cmdlets.
.NOTES
    Requires an active Microsoft Graph connection (see connect-azure.ps1).
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

    $profiles = @(
        @{
            "@odata.type"                  = "#microsoft.graph.windows10GeneralConfiguration"
            displayName                    = "Windows 11 Restrictions"
            description                    = "Blocks USB storage and sets the managed desktop wallpaper"
            usbBlocked                     = $true
            personalizationDesktopImageUrl = "https://drive.google.com/thumbnail?id=18OI-tc-jqWazuU7VHMphPDRC2rtr8mgX&sz=w1920-h1080"
        },
        @{
            "@odata.type"                       = "#microsoft.graph.windowsUpdateForBusinessConfiguration"
            displayName                         = "Windows 11 Update Ring"
            description                         = "Defers quality and feature updates for controlled rollout"
            qualityUpdatesDeferralPeriodInDays  = 7
            featureUpdatesDeferralPeriodInDays  = 30
            automaticUpdateMode                 = "autoInstallAtMaintenanceTime"
        }
    )

    foreach ($profile in $profiles) {
        $newProfile = New-MgDeviceManagementDeviceConfiguration -BodyParameter $profile -ErrorAction Stop

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
            -Uri "https://graph.microsoft.com/v1.0/deviceManagement/deviceConfigurations/$($newProfile.Id)/assign" `
            -Body ($assignmentBody | ConvertTo-Json -Depth 5) `
            -ErrorAction Stop

        Write-Host "Created and assigned: $($newProfile.DisplayName) [$($newProfile.Id)]" -ForegroundColor Green
    }

    Write-Host "Success!" -ForegroundColor Green
}
catch {
    Write-Host "Failed: $_" -ForegroundColor Red
}