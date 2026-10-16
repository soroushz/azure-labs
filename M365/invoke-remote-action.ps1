<#
.SYNOPSIS
    Sends a remote action (Lock, Retire, or Wipe) to a managed Intune device.
.DESCRIPTION
    Looks up the device by name and triggers the matching Graph remote action.
    Run this once per action, in order: Lock, then Retire, then Wipe last —
    Wipe resets the device, so nothing else can be tested on it afterward.
.NOTES
    Requires an active Microsoft Graph connection (see connect-azure.ps1), with
    DeviceManagementManagedDevices.ReadWrite.All and
    DeviceManagementManagedDevices.PrivilegedOperations.All permissions.
    Uses the Graph beta endpoint for the action call — v1.0 was returning a
    generic 400 error for this one.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$DeviceName,

    [Parameter(Mandatory = $true)]
    [ValidateSet("Lock", "Retire", "Wipe")]
    [string]$Action
)

try {
    if (-not (Get-MgContext)) {
        throw "Not connected to Microsoft Graph. Run .\connect-azure.ps1 first."
    }

    $actionEndpoints = @{
        "Lock"   = "remoteLock"
        "Retire" = "retire"
        "Wipe"   = "wipe"
    }
    $endpoint = $actionEndpoints[$Action]

    $device = Get-MgDeviceManagementManagedDevice -Filter "deviceName eq '$DeviceName'"
    if (-not $device) {
        throw "Device '$DeviceName' not found in Intune."
    }
    $deviceId = $device.Id

        Invoke-MgGraphRequest -Method POST `
        -Uri "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/$deviceId/$endpoint" `
        -Body "{}" `
        -ContentType "application/json" `
        -ErrorAction Stop

    Write-Host "Sent '$Action' to device: $DeviceName [$deviceId]" -ForegroundColor Green
    Write-Host "Success!" -ForegroundColor Green
}
catch {
    Write-Host "Failed: $_" -ForegroundColor Red
}