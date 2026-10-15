<#
.SYNOPSIS
    Creates one or more lab VMs on the cheapest practical tier:
    Standard_B-series compute + Standard HDD disk + Standard SKU public IP
    (Basic SKU public IPs are retired on this subscription).
    Array-driven so more VMs can be added later without touching the logic.
#>

$vmDefinitions = @(
    @{
        VMName            = "monitor-vm"
        ResourceGroupName = "secops-rg"
        Location          = "UK West"
        Size              = "Standard_D2al_v6"
        AdminUsername     = "localadmin"
    }
)

foreach ($vm in $vmDefinitions) {
    try {
        Write-Host "Creating VM: $($vm.VMName)..." -ForegroundColor Cyan

        New-AzResourceGroup -Name $vm.ResourceGroupName -Location $vm.Location -Force -ErrorAction Stop | Out-Null

        $subnetConfig = New-AzVirtualNetworkSubnetConfig -Name "default" -AddressPrefix "10.10.1.0/24"
        $vnet = New-AzVirtualNetwork -ResourceGroupName $vm.ResourceGroupName -Location $vm.Location `
            -Name "$($vm.VMName)-vnet" -AddressPrefix "10.10.0.0/16" -Subnet $subnetConfig -ErrorAction Stop

        $rdpRule = New-AzNetworkSecurityRuleConfig -Name "Allow-RDP" -Protocol Tcp -Direction Inbound -Priority 1000 `
            -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389 -Access Allow

        $nsg = New-AzNetworkSecurityGroup -ResourceGroupName $vm.ResourceGroupName -Location $vm.Location `
            -Name "$($vm.VMName)-nsg" -SecurityRules $rdpRule -ErrorAction Stop

        $pip = New-AzPublicIpAddress -ResourceGroupName $vm.ResourceGroupName -Location $vm.Location `
            -Name "$($vm.VMName)-pip" -AllocationMethod Static -Sku Standard -ErrorAction Stop

        $nic = New-AzNetworkInterface -ResourceGroupName $vm.ResourceGroupName -Location $vm.Location `
            -Name "$($vm.VMName)-nic" -SubnetId $vnet.Subnets[0].Id `
            -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id -ErrorAction Stop

        $securePassword = Read-Host -Prompt "Enter admin password for $($vm.VMName)" -AsSecureString
        $credential = New-Object System.Management.Automation.PSCredential ($vm.AdminUsername, $securePassword)

        $vmConfig = New-AzVMConfig -VMName $vm.VMName -VMSize $vm.Size |
            Set-AzVMOperatingSystem -Windows -ComputerName $vm.VMName -Credential $credential |
            Set-AzVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2022-Datacenter" -Version "latest" |
            Add-AzVMNetworkInterface -Id $nic.Id |
            Set-AzVMOSDisk -StorageAccountType "Standard_LRS" -CreateOption FromImage

        New-AzVM -ResourceGroupName $vm.ResourceGroupName -Location $vm.Location -VM $vmConfig -ErrorAction Stop

        Write-Host "Created: $($vm.VMName)" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to create $($vm.VMName): $($_.Exception.Message)" -ForegroundColor Red
    }
}
