# Define assignments - edit this section to customize
$assignments = @(
    @{ Group="Finance-Team"; Role="VM Reader Plus" }
)

# Get subscription ID dynamically
try {
    $subId = (Get-AzSubscription -SubscriptionName "Azure Subscription 1" -ErrorAction Stop).Id
} catch {
    Write-Host "Could not find subscription 'Azure Subscription 1': $_" -ForegroundColor Red
    return
}

# Process each assignment
foreach ($a in $assignments) {
    try {
        $groupId = (Get-MgGroup -Filter "displayName eq '$($a.Group)'" -ErrorAction Stop).Id

        if (-not $groupId) {
            throw "Group '$($a.Group)' not found"
        }

        New-AzRoleAssignment `
            -ObjectId $groupId `
            -RoleDefinitionName $a.Role `
            -Scope "/subscriptions/$subId" `
            -ErrorAction Stop
        Write-Host "$($a.Group) assigned $($a.Role) role" -ForegroundColor Green
    } catch {
        Write-Host "Failed to assign $($a.Role) to $($a.Group): $_" -ForegroundColor Red
    }
}