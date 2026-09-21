# Define Role Assignments 
$roleAssignments = @( 
	@{ Group="HR-Team";   Role="Reader" },
	@{ Group="IT-Admins"; Role="Contributor" }
)

$subId = (Get-AzSubscription -SubscriptionName "Azure subscription 1").Id 

foreach($r in $roleAssignments) {
	$groupId = (Get-MgGroup -Filter "displayName eq '$($r.Group)'").Id 
	New-AzRoleAssignment -ObjectId $groupId `
		-RoleDefinitionName $r.Role `
		-Scope "/subscriptions/$subId"
	Write-Host "$($r.Group) assigned $($r.Role) role" -ForegroundColor Green
}