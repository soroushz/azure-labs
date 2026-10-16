<#
.SYNOPSIS
    Creates shared mailboxes in Exchange Online and grants access permissions.
.DESCRIPTION
    Loops through an array of shared mailbox definitions, creates each one, then
    grants the specified user Full Access (read/manage) and Send As permissions.
.NOTES
    Requires an active Exchange Online connection (see connect-exo.ps1).
#>

param()

try {
    if (-not (Get-ConnectionInformation)) {
        throw "Not connected to Exchange Online. Run .\connect-exo.ps1 first."
    }

    $sharedMailboxes = @(
        @{
            Name          = "IT-Support"
            DisplayName   = "IT Support"
            EmailAddress  = "it-support@contoso.onmicrosoft.com"
            FullAccessUser = "John Smith"
            SendAsUser    = "John Smith"
        }
    )

    foreach ($mailbox in $sharedMailboxes) {
        try {
            New-Mailbox -Shared `
                -Name $mailbox.Name `
                -DisplayName $mailbox.DisplayName `
                -PrimarySmtpAddress $mailbox.EmailAddress `
                -ErrorAction Stop | Out-Null

            Add-MailboxPermission -Identity $mailbox.Name `
                -User $mailbox.FullAccessUser `
                -AccessRights FullAccess `
                -InheritanceType All `
                -AutoMapping $true `
                -ErrorAction Stop | Out-Null

            Add-RecipientPermission -Identity $mailbox.Name `
                -Trustee $mailbox.SendAsUser `
                -AccessRights SendAs `
                -Confirm:$false `
                -ErrorAction Stop | Out-Null

            Write-Host "Created shared mailbox: $($mailbox.Name) (access: $($mailbox.FullAccessUser))" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed on '$($mailbox.Name)': $_" -ForegroundColor Red
        }
    }

    Write-Host "Success!" -ForegroundColor Green
}
catch {
    Write-Host "Failed: $_" -ForegroundColor Red
}