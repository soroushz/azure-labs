# Get HR-Team members
$groupId = (Get-MgGroup -Filter "displayName eq 'HR-Team'").Id 
$members = (Get-MgGroupMember -GroupId $groupId)

foreach ($member in $members) {
	try { 
		# Enable SMS authentication for each HR-Team member
		New-MgUserAuthenticationPhoneMethod `
			-UserId $member.Id `
			-PhoneType "mobile" `
			-PhoneNumber "+1 4165550100"
		Write-Host "SMS MFA enabled for $($member.Id)" -ForegroundColor Green 
	} catch {
	    	Write-Host "Failed for $($member.Id): $_" -ForegroundColor Red 
	}
}

Write-Host "MFA configuration complete for HR-Team!" -ForegroundColor Cyan 

