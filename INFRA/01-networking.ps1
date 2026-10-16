# create-vnet-project2.ps1
# Creates a resource group (if missing) and a VNet with WebSubnet/DBSubnet attached.
# Requires: PowerShell 7 (Az module), signed in via connect-azure.ps1.
# Add more subnets by adding entries to $subnets below - no other changes needed.

$resourceGroup    = "rg-project2-networking"
$location         = "eastus"
$vnetName         = "Project2-VNet"
$vnetAddressSpace = "10.0.0.0/16"

$subnets = @(
    @{ Name = "WebSubnet"; Prefix = "10.0.1.0/24" },
    @{ Name = "DBSubnet";  Prefix = "10.0.2.0/24" }
)

# Idempotent - safe to re-run without erroring on a duplicate RG
$rg = Get-AzResourceGroup -Name $resourceGroup -ErrorAction SilentlyContinue
if (-not $rg) {
    try {
        New-AzResourceGroup -Name $resourceGroup -Location $location -ErrorAction Stop
        Write-Host "Resource group '$resourceGroup' created" -ForegroundColor Green
    } catch {
        Write-Host "Failed to create resource group: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Resource group '$resourceGroup' already exists, skipping" -ForegroundColor Yellow
}

# Build subnet configs from the array, then apply all at once below
$subnetConfigs = @()
foreach ($s in $subnets) {
    try {
        $config = New-AzVirtualNetworkSubnetConfig -Name $s.Name -AddressPrefix $s.Prefix
        $subnetConfigs += $config
        Write-Host "Subnet config built: $($s.Name) ($($s.Prefix))" -ForegroundColor Green
    } catch {
        Write-Host "Failed to build subnet config for $($s.Name): $_" -ForegroundColor Red
    }
}

try {
    New-AzVirtualNetwork `
        -Name $vnetName `
        -ResourceGroupName $resourceGroup `
        -Location $location `
        -AddressPrefix $vnetAddressSpace `
        -Subnet $subnetConfigs `
        -ErrorAction Stop

    Write-Host "VNet '$vnetName' created with $($subnetConfigs.Count) subnets" -ForegroundColor Cyan
} catch {
    Write-Host "Failed to create VNet: $_" -ForegroundColor Red
}