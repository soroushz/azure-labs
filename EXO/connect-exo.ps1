<#
.SYNOPSIS
    Connects to Exchange Online using certificate-based app-only authentication.
.DESCRIPTION
    Logs in to Exchange Online PowerShell as the app (not as a user), using the
    certificate created by create-exo-certificate.ps1 and uploaded to the App
    Registration, plus the Exchange Administrator role assigned by assign-exo-role.ps1.
.NOTES
    Requires the ExchangeOnlineManagement module:
      Install-Module ExchangeOnlineManagement -Scope CurrentUser
#>

param(
    [string]$AppId = "<your-app-id>",
    [string]$CertThumbprint = "<your-cert-thumbprint>",
    [string]$Organization = "contoso.onmicrosoft.com"
)

try {
    Import-Module ExchangeOnlineManagement -ErrorAction Stop

    Connect-ExchangeOnline -AppId $AppId `
        -CertificateThumbprint $CertThumbprint `
        -Organization $Organization `
        -ShowBanner:$false `
        -ErrorAction Stop

    $session = Get-ConnectionInformation
    Write-Host "Connected to Exchange Online as app: $($session.UserPrincipalName)" -ForegroundColor Green
    Write-Host "Success!" -ForegroundColor Green
}
catch {
    Write-Host "Failed: $_" -ForegroundColor Red
}