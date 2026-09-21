# Define assignments - edit this section to customize
$assignments = @(
    @{ Group="Finance-Team"; Role="VM Reader Plus" }
)

# Get subscription ID dynamically
$subId = (Get-AzSubscription -SubscriptionName "Azure Subscription 1").Id

# Process each assignment
foreach ($a in $assignments) {
    $groupId = (Get-MgGroup -Filter "displayName eq '$($a.Group)'").Id
    
    if ($groupId) {
        New-AzRoleAssignment `
            -ObjectId $groupId `
            -RoleDefinitionName $a.Role `
            -Scope "/subscriptions/$subId"
        Write-Host "$($a.Group) assigned $($a.Role) role" -ForegroundColor Green
    } else {
        Write-Host "Group '$($a.Group)' not found" -ForegroundColor Red
    }
}