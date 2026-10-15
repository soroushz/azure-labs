<#
.SYNOPSIS
    Creates an Action Group (who gets notified) and one or more Metric
    Alert Rules (what triggers it) for Azure Monitor.
    Array-driven so more alert rules can be added later without
    touching the logic.
#>

$resourceGroupName = "secops-rg"

$actionGroups = @(
    @{
        Name      = "secops-ag"
        ShortName = "secopsAG"
        Email     = "YOUR-EMAIL-HERE@example.com"
    }
)

$alertRules = @(
    @{
        Name            = "High-CPU-Alert"
        VMName          = "monitor-vm"
        MetricName      = "Percentage CPU"
        Threshold       = 70
        Severity        = 2
        ActionGroupName = "secops-ag"
    }
)

$createdActionGroups = @{}

foreach ($ag in $actionGroups) {
    try {
        Write-Host "Creating action group: $($ag.Name)..." -ForegroundColor Cyan

        $emailReceiver = New-AzActionGroupEmailReceiverObject -Name "EmailReceiver" -EmailAddress $ag.Email

        $result = New-AzActionGroup -ResourceGroupName $resourceGroupName -Name $ag.Name `
            -ShortName $ag.ShortName -EmailReceiver $emailReceiver -Location "Global" -ErrorAction Stop

        $createdActionGroups[$ag.Name] = $result.Id
        Write-Host "Created action group: $($ag.Name)" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to create action group $($ag.Name): $($_.Exception.Message)" -ForegroundColor Red
    }
}

foreach ($rule in $alertRules) {
    try {
        Write-Host "Creating alert rule: $($rule.Name)..." -ForegroundColor Cyan

        $vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $rule.VMName -ErrorAction Stop

        $condition = New-AzMetricAlertRuleV2Criteria -MetricName $rule.MetricName `
            -TimeAggregation Average -Operator GreaterThan -Threshold $rule.Threshold

        $actionGroupId = $createdActionGroups[$rule.ActionGroupName]

        Add-AzMetricAlertRuleV2 -Name $rule.Name -ResourceGroupName $resourceGroupName `
            -WindowSize 00:05:00 -Frequency 00:01:00 -TargetResourceId $vm.Id `
            -Condition $condition -ActionGroupId $actionGroupId -Severity $rule.Severity `
            -ErrorAction Stop

        Write-Host "Created alert rule: $($rule.Name)" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to create alert rule $($rule.Name): $($_.Exception.Message)" -ForegroundColor Red
    }
}
