<#
.SYNOPSIS
    Creates a Log Analytics workspace and routes a VM's metrics into it
    via a diagnostic setting, so the CPU data is captured as a queryable
    historical record instead of just showing up in alerts and graphs.
    Array-driven so more workspaces/VMs could be added later without
    touching the logic.
#>

$resourceGroupName = "secops-rg"

$workspaces = @(
    @{
        Name     = "secops-law"
        Location = "UK West"
    }
)

$diagnosticSettings = @(
    @{
        Name          = "monitor-vm-to-law"
        VMName        = "monitor-vm"
        WorkspaceName = "secops-law"
    }
)

$createdWorkspaces = @{}

foreach ($ws in $workspaces) {
    try {
        Write-Host "Creating Log Analytics workspace: $($ws.Name)..." -ForegroundColor Cyan

        $result = New-AzOperationalInsightsWorkspace -ResourceGroupName $resourceGroupName `
            -Name $ws.Name -Location $ws.Location -Sku "PerGB2018" -ErrorAction Stop

        $createdWorkspaces[$ws.Name] = $result.ResourceId
        Write-Host "Created workspace: $($ws.Name)" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to create workspace $($ws.Name): $($_.Exception.Message)" -ForegroundColor Red
    }
}

foreach ($diag in $diagnosticSettings) {
    try {
        Write-Host "Routing $($diag.VMName) metrics to $($diag.WorkspaceName)..." -ForegroundColor Cyan

        $vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $diag.VMName -ErrorAction Stop
        $workspaceId = $createdWorkspaces[$diag.WorkspaceName]

        $metricSetting = New-AzDiagnosticSettingMetricSettingsObject -Enabled $true -Category "AllMetrics"

        New-AzDiagnosticSetting -Name $diag.Name -ResourceId $vm.Id `
            -WorkspaceId $workspaceId -Metric $metricSetting -ErrorAction Stop

        Write-Host "Routed: $($diag.Name)" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to create diagnostic setting $($diag.Name): $($_.Exception.Message)" -ForegroundColor Red
    }
}
