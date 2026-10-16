<#
.SYNOPSIS
    Creates self-signed certificates for app-only authentication (e.g. Exchange Online).
.DESCRIPTION
    Loops through an array of certificate definitions, creates each one in the local
    certificate store, and exports its public key as a .cer file for upload to an
    Entra ID App Registration.
.NOTES
    Run this in a normal PowerShell window (not as admin needed for CurrentUser store).
    The private key stays on this machine — only the exported .cer (public key) gets
    uploaded to Entra ID.
#>

param(
    [string]$ExportFolder = "C:\Users\Mo\azure-scripts\certs"
)

try {
    if (-not (Test-Path $ExportFolder)) {
        New-Item -ItemType Directory -Path $ExportFolder -Force | Out-Null
    }

    $certConfigs = @(
        @{
            Name       = "EXO-AppOnlyCert"
            YearsValid = 2
        }
    )

    foreach ($config in $certConfigs) {
        $cert = New-SelfSignedCertificate -Subject "CN=$($config.Name)" `
            -CertStoreLocation "Cert:\CurrentUser\My" `
            -KeyExportPolicy Exportable `
            -KeySpec Signature `
            -KeyLength 2048 `
            -NotAfter (Get-Date).AddYears($config.YearsValid) `
            -ErrorAction Stop

        $exportPath = Join-Path $ExportFolder "$($config.Name).cer"
        Export-Certificate -Cert $cert -FilePath $exportPath -ErrorAction Stop | Out-Null

        Write-Host "Created certificate: $($config.Name)" -ForegroundColor Green
        Write-Host "  Thumbprint: $($cert.Thumbprint)" -ForegroundColor Yellow
        Write-Host "  Exported public key to: $exportPath" -ForegroundColor Green
    }

    Write-Host "Success!" -ForegroundColor Green
}
catch {
    Write-Host "Failed: $_" -ForegroundColor Red
}