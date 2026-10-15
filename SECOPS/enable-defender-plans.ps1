<#
.SYNOPSIS
    Enables one or more Microsoft Defender for Cloud plans on this subscription.
    Array-driven so more plans can be enabled later without touching the logic.
#>

$defenderPlans = @(
    @{
        Name        = "VirtualMachines"
        PricingTier = "Standard"
    }
)

foreach ($plan in $defenderPlans) {
    try {
        Write-Host "Enabling Defender plan: $($plan.Name) ($($plan.PricingTier))..." -ForegroundColor Cyan

        Set-AzSecurityPricing -Name $plan.Name -PricingTier $plan.PricingTier -ErrorAction Stop

        Write-Host "Enabled: $($plan.Name)" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to enable $($plan.Name): $($_.Exception.Message)" -ForegroundColor Red
    }
}
