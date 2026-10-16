<#
.SYNOPSIS
    Creates mail flow (transport) rules in Exchange Online.
.DESCRIPTION
    Loops through an array of rule definitions and creates each one, branching on
    rule Type: SubjectBlock (reject emails with a keyword in the subject) or
    Disclaimer (append a disclaimer to messages).
.NOTES
    Requires an active Exchange Online connection (see connect-exo.ps1).
#>

param()

try {
    if (-not (Get-ConnectionInformation)) {
        throw "Not connected to Exchange Online. Run .\connect-exo.ps1 first."
    }

    $mailFlowRules = @(
        @{
            Name    = "Block-Password-In-Subject"
            Type    = "SubjectBlock"
            Keyword = "password"
        },
        @{
            Name            = "Append-Confidentiality-Disclaimer"
            Type            = "Disclaimer"
            DisclaimerText  = "<p style='font-size:11px;color:gray;'>This message and any attachments are confidential and intended only for the named recipient(s).</p>"
        }
    )

    foreach ($rule in $mailFlowRules) {
        try {
            switch ($rule.Type) {
                "SubjectBlock" {
                    New-TransportRule -Name $rule.Name `
                        -SubjectContainsWords $rule.Keyword `
                        -RejectMessageReasonText "Emails containing '$($rule.Keyword)' in the subject are blocked for security reasons. Please share credentials through a secure method instead." `
                        -ErrorAction Stop | Out-Null
                }
                "Disclaimer" {
                    New-TransportRule -Name $rule.Name `
                        -ApplyHtmlDisclaimerLocation Append `
                        -ApplyHtmlDisclaimerText $rule.DisclaimerText `
                        -ApplyHtmlDisclaimerFallbackAction Wrap `
                        -ErrorAction Stop | Out-Null
                }
            }

            Write-Host "Created rule: $($rule.Name)" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed on '$($rule.Name)': $_" -ForegroundColor Red
        }
    }

    Write-Host "Success!" -ForegroundColor Green
}
catch {
    Write-Host "Failed: $_" -ForegroundColor Red
}