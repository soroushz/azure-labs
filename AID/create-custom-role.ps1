try {
# Get subscription ID
$subId = (Get-AzSubscription -SubscriptionName "Azure Subscription 1" -ErrorAction Stop).Id

# Create role definition as JSON (new format)
$roleJson = @"
{
    "Name": "VM Reader Plus",
    "Description": "Can view and restart VMs but cannot create or delete them",
    "IsCustom": true,
    "Permissions": [
        {
            "Actions": [
                "Microsoft.Compute/virtualMachines/read",
                "Microsoft.Compute/virtualMachines/restart/action",
                "Microsoft.Compute/virtualMachines/start/action"
            ],
            "NotActions": [],
            "DataActions": [],
            "NotDataActions": []
        }
    ],
    "AssignableScopes": [
        "/subscriptions/$subId"
    ]
}
"@

# Save JSON to a temp file
$roleFile = Join-Path $env:TEMP "custom-role.json"
$roleJson | Out-File $roleFile

# Create the role from JSON file
New-AzRoleDefinition -InputFile $roleFile -ErrorAction Stop
Write-Host "Custom role 'VM Reader Plus' created!" -ForegroundColor Green
} catch {
    Write-Host "Failed to create custom role: $_" -ForegroundColor Red
}