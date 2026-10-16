# Each HR-Team member's own phone number for SMS MFA registration.
# Add more entries here to cover additional team members.
$phoneAssignments = @(
	@{ UserPrincipalName = "sarah.johnson@yourtenant.onmicrosoft.com"; PhoneNumber = "+1 4165550100" }
)

foreach ($assignment in $phoneAssignments) {
	try {
		$user = Get-MgUser -UserId $assignment.UserPrincipalName -ErrorAction Stop

		# Enable SMS authentication for this member
		New-MgUserAuthenticationPhoneMethod `
			-UserId $user.Id `
			-PhoneType "mobile" `
			-PhoneNumber $assignment.PhoneNumber `
			-ErrorAction Stop
		Write-Host "SMS MFA enabled for $($assignment.UserPrincipalName)" -ForegroundColor Green
	} catch {
		Write-Host "Failed for $($assignment.UserPrincipalName): $_" -ForegroundColor Red
	}
}

Write-Host "MFA configuration complete!" -ForegroundColor Cyan

