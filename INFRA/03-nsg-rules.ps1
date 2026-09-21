# create-nsg-rules.ps1
$resourceGroup = "rg-project2-networking"

$rules = @(
    @{NsgName = "WebVM-nsg"; RuleName = "Allow-HTTP";            Priority = "110"; Access = "Allow"; Protocol = "TCP"; SourceAddressPrefix = "Internet";     DestinationAddressPrefix = "*"; DestinationPortRange = "80"}
    @{NsgName = "WebVM-nsg"; RuleName = "Allow-HTTPS";           Priority = "120"; Access = "Allow"; Protocol = "TCP"; SourceAddressPrefix = "Internet";     DestinationAddressPrefix = "*"; DestinationPortRange = "443"}
    @{NsgName = "DBVM-nsg";  RuleName = "Allow-SQL-From-Web";    Priority = "130"; Access = "Allow"; Protocol = "TCP"; SourceAddressPrefix = "10.0.1.0/24"; DestinationAddressPrefix = "*"; DestinationPortRange = "1433"}
    @{NsgName = "DBVM-nsg";  RuleName = "Deny-Internet-Inbound"; Priority = "140"; Access = "Deny";  Protocol = "TCP"; SourceAddressPrefix = "Internet";     DestinationAddressPrefix = "*"; DestinationPortRange = "*"}
)

foreach ($rule in $rules) {
    try {
        $nsg = Get-AzNetworkSecurityGroup -Name $rule.NsgName -ResourceGroupName $resourceGroup -ErrorAction Stop

        Add-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg -Name $rule.RuleName -Priority $rule.Priority `
            -Direction "Inbound" -Access $rule.Access -Protocol $rule.Protocol `
            -SourceAddressPrefix $rule.SourceAddressPrefix -SourcePortRange "*" `
            -DestinationAddressPrefix $rule.DestinationAddressPrefix -DestinationPortRange $rule.DestinationPortRange | Out-Null

        Set-AzNetworkSecurityGroup -NetworkSecurityGroup $nsg -ErrorAction Stop | Out-Null
        Write-Host "Added rule '$($rule.RuleName)' to $($rule.NsgName)" -ForegroundColor Green
    } catch {
        Write-Host "Failed to add rule '$($rule.RuleName)' to $($rule.NsgName): $_" -ForegroundColor Red
    }
}