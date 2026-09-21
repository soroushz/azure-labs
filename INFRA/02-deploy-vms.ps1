# create-vms.ps1
# Creates WebVM (Windows Server 2022, WebSubnet) and DBVM (Ubuntu 22.04, DBSubnet)
# in the existing Project2-VNet. Prompts for admin credentials via secure popup.
#
# Gotchas this version fixes:
# - Az cmdlet errors are non-terminating by default, so -ErrorAction Stop is
#   required or the catch block never fires and you get false "created" messages.
# - "Win2022Datacenter" alias stopped resolving -> using the full image URN
#   (publisher:offer:sku:version) instead, since aliases can drift across
#   Az module versions.
# - Standard_B1s and Standard_B2s both hit capacity restrictions in eastus ->
#   moved to Standard_D2alds_v7, confirmed available via the portal.
# - If the WebVM image errors again, run:
#   Get-AzVMImageSku -Location "eastus" -PublisherName "MicrosoftWindowsServer" `
#     -Offer "WindowsServer" | Where-Object { $_.Skus -like "*hotpatch*" }
#   and swap in whatever exact SKU string comes back.

$resourceGroup = "rg-project2-networking"
$location      = "eastus"
$vnetName      = "Project2-VNet"
$vmSize        = "Standard_D2alds_v7"

$vms = @(
    @{ Name = "WebVM"; Subnet = "WebSubnet"; Image = "MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition-hotpatch:latest"; OpenPort = 3389 },
    @{ Name = "DBVM";  Subnet = "DBSubnet";  Image = "Ubuntu2204"; OpenPort = 22 }
)

$cred = Get-Credential -Message "Enter the admin username/password to use for both VMs"

foreach ($vm in $vms) {
    try {
        New-AzVM `
            -ResourceGroupName $resourceGroup `
            -Name $vm.Name `
            -Location $location `
            -VirtualNetworkName $vnetName `
            -SubnetName $vm.Subnet `
            -SecurityGroupName "$($vm.Name)-nsg" `
            -PublicIpAddressName "$($vm.Name)-pip" `
            -OpenPorts $vm.OpenPort `
            -Image $vm.Image `
            -Size $vmSize `
            -Credential $cred `
            -ErrorAction Stop

        Write-Host "$($vm.Name) created in $($vm.Subnet)" -ForegroundColor Green
    } catch {
        Write-Host "Failed to create $($vm.Name): $_" -ForegroundColor Red
    }
}