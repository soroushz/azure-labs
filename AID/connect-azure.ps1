# connect-azure.ps1
# Connects to Microsoft Graph and Az as the automation service principal.
# Credentials are never stored in this file. Set these environment variables first:
#   $env:AZURE_TENANT_ID     - Entra tenant (directory) ID
#   $env:AZURE_CLIENT_ID     - app registration (client) ID
# The client secret is prompted for at runtime via a secure popup.

$tenantId = $env:AZURE_TENANT_ID
$clientId = $env:AZURE_CLIENT_ID

if (-not $tenantId -or -not $clientId) {
    Write-Host "Set AZURE_TENANT_ID and AZURE_CLIENT_ID environment variables first." -ForegroundColor Red
    return
}

$secureSecret = (Get-Credential -UserName $clientId -Message "Enter the client secret as the password").Password
$credential = New-Object System.Management.Automation.PSCredential($clientId, $secureSecret)

try {
    # Connect to Microsoft Graph
    Connect-MgGraph -TenantId $tenantId -ClientSecretCredential $credential -ErrorAction Stop
    Write-Host "Connected to Microsoft Graph!" -ForegroundColor Green

    # Connect to Az
    Connect-AzAccount -ServicePrincipal -TenantId $tenantId -Credential $credential -ErrorAction Stop
    Write-Host "Connected to Az!" -ForegroundColor Green
} catch {
    Write-Host "Failed to connect: $_" -ForegroundColor Red
}
