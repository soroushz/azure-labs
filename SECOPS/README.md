# 🛡️ SECOPS — Monitoring & Security

`Azure Monitor` `Defender for Cloud` `Log Analytics` `KQL` `PowerShell`

Real-time monitoring and threat detection for Azure infrastructure — watching for problems instead of hoping nothing breaks. Built in a lab environment and automated end-to-end with PowerShell (Az module).

## What's covered

- **Monitor Alerts** — an Action Group (email notification) and a Metric Alert Rule watching VM CPU, checked every minute over a 5-minute window. Tested for real: spiked the VM's CPU and confirmed the alert actually fired and the email actually landed.
- **Defender for Cloud** — enabled the Standard plan (Defender for Servers) on the subscription, turning basic free-tier posture checks into real threat detection with actual security recommendations against the VM.
- **Log Analytics & KQL** — a Log Analytics workspace with VM metrics routed into it via a diagnostic setting, queried with KQL to pull real CPU history back out.

## Scripts

- `create-lab-vm.ps1` — provisions the lab VM used across this project (Standard HDD disk, Standard SKU public IP, explicit RDP rule)
- `create-monitor-alert.ps1` — creates the Action Group and Metric Alert Rule
- `enable-defender-plans.ps1` — enables Defender for Cloud's Standard plan
- `create-log-analytics.ps1` — creates the Log Analytics workspace and routes VM metrics into it

## Status

🟡 In Progress
