# 💻 M365 — Microsoft 365 & Intune

`Intune` `M365` `Device Enrollment` `Compliance Policies` `Configuration Profiles` `App Deployment` `Remote Actions` `PowerShell` `Microsoft Graph API`

A Windows 11 Intune lab built end to end for real device management — enrollment, compliance policies, configuration profiles, app deployment, and retiring/wiping a lost or departing employee's device. Built in a Hyper-V lab and a Microsoft 365 Business Premium tenant, automated end-to-end with Microsoft Graph PowerShell.

## What's covered

- **Lab Device Setup** — a Generation 2 Hyper-V VM with virtual TPM and Secure Boot, required for BitLocker compliance testing later.
- **Tenant & Licensing Setup** — a Microsoft 365 Business Premium trial, with the test user licensed for Intune enrollment.
- **Device Enrollment** — the VM enrolled through the real "Access work or school" sign-in flow, not a forced admin push.
- **Compliance Policies** — a Windows 11 Baseline Compliance policy (BitLocker, strong password, minimum OS build), assigned to IT-Admins.
- **Configuration Profiles** — Windows 11 Restrictions (USB block, managed wallpaper) and a Windows 11 Update Ring, both assigned to IT-Admins.
- **App Deployment** — Microsoft 365 Apps for Windows deployed as a required install via the Graph beta endpoint.
- **Remote Actions** — Retire and Wipe tested against the enrolled device for a lost/departing-employee scenario.

## Scripts

All four scripts need an active Microsoft Graph session first (`connect-azure.ps1` in [AID](../AID)).

- `create-compliance-policy.ps1` — creates the Windows 11 Baseline Compliance policy (BitLocker, strong password, minimum OS build) and assigns it to `IT-Admins`
- `create-config-profiles.ps1` — creates the Windows 11 Restrictions and Windows 11 Update Ring profiles and assigns them to `IT-Admins`
- `create-app-deployment.ps1` — deploys Microsoft 365 Apps for Windows as a required install via the Graph beta endpoint
- `invoke-remote-action.ps1` — sends a Lock, Retire or Wipe remote action to a managed device by name

## Status

✅ Complete
