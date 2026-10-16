# Define Role Assignments 
$roleAssignments = @( 
	@{ Group="HR-Team";   Role="Reader" },
	@{ Group="IT-Admins"; Role="Contributor" }
)

try {
	$subId = (Get-AzSubscription -SubscriptionName "Azure subscription 1" -ErrorAction Stop).Id
} catch {
	Write-Host "Could not find subscription 'Azure subscription 1': $_" -ForegroundColor Red
	return
}

foreach($r in $roleAssignments) {
	try {
		$groupId = (Get-MgGroup -Filter "displayName eq '$($r.Group)'" -ErrorAction Stop).Id
		if (-not $groupId) {
			throw "Group '$($r.Group)' not found"
		}

		New-AzRoleAssignment -ObjectId $groupId `
			-RoleDefinitionName $r.Role `
			-Scope "/subscriptions/$subId" `
			-ErrorAction Stop
		Write-Host "$($r.Group) assigned $($r.Role) role" -ForegroundColor Green
	} catch {
		Write-Host "Failed to assign $($r.Role) to $($r.Group): $_" -ForegroundColor Red
	}
}