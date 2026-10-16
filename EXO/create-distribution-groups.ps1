<#
.SYNOPSIS
    Creates distribution groups in Exchange Online and adds members to each.
.DESCRIPTION
    Loops through an array of distribution group definitions, creates each group,
    then loops through that group's member list and adds each one.
.NOTES
    Requires an active Exchange Online connection (see connect-exo.ps1).
#>

param()

try {
    if (-not (Get-ConnectionInformation)) {
        throw "Not connected to Exchange Online. Run .\connect-exo.ps1 first."
    }

    $distributionGroups = @(
        @{
            Name         = "All-Staff"
            DisplayName  = "All Staff"
            EmailAddress = "all-staff@contoso.onmicrosoft.com"
            Members      = @("John Smith")
        }
    )

    foreach ($group in $distributionGroups) {
        try {
            New-DistributionGroup -Name $group.Name `
                -DisplayName $group.DisplayName `
                -PrimarySmtpAddress $group.EmailAddress `
                -Type Distribution `
                -ErrorAction Stop | Out-Null

            foreach ($member in $group.Members) {
                Add-DistributionGroupMember -Identity $group.Name `
                    -Member $member `
                    -ErrorAction Stop
            }

            Write-Host "Created group: $($group.Name) with $($group.Members.Count) member(s)" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed on '$($group.Name)': $_" -ForegroundColor Red
        }
    }

    Write-Host "Success!" -ForegroundColor Green
}
catch {
    Write-Host "Failed: $_" -ForegroundColor Red
}