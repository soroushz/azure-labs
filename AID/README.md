# 🔐 AID — Azure Identity & Access Management

`Entra ID` `RBAC` `PowerShell` `Microsoft Graph API` `MFA` `Conditional Access` `Least Privilege`

A complete identity and access management setup in Microsoft Azure — the most critical skill for any Azure administrator. Built in a dedicated lab environment, isolated from any work/school account, and automated with PowerShell and the Microsoft Graph API.

## What's covered

- **Users & Groups** — test users provisioned per department (IT, HR, Finance) via `Invoke-MgGraphRequest` against the Graph API, plus security groups and bulk group assignment, all scripted instead of clicked through the portal.
- **RBAC Roles** — built-in role assignment, a custom role definition, and custom role assignment, with before/after verification that access is actually restricted as expected.
- **MFA Configuration** — authentication method policies applied per team (HR), with a live authentication test.
- **Conditional Access Policies** — three policies: require MFA for all users, block sign-in from outside Canada (named location), and require a compliant device for the Finance team.

## Scripts

No credentials are stored in this repo. `connect-azure.ps1` reads `AZURE_TENANT_ID` / `AZURE_CLIENT_ID` from environment variables and prompts for the client secret.

- [`connect-azure.ps1`](./connect-azure.ps1) — signs in to Microsoft Graph and Az as the automation service principal
- [`assign-groups.ps1`](./assign-groups.ps1) — adds users to department groups from an inline list
- [`assign-users-to-groups.ps1`](./assign-users-to-groups.ps1) — bulk version of the above, driven by a CSV (see [`user-group-assignments.example.csv`](./user-group-assignments.example.csv))
- [`assign-rbac.ps1`](./assign-rbac.ps1) — assigns built-in roles (Reader, Contributor) to groups at subscription scope
- [`create-custom-role.ps1`](./create-custom-role.ps1) — defines the custom `VM Reader Plus` role (view, start and restart VMs only)
- [`assign-custom-role.ps1`](./assign-custom-role.ps1) — assigns the custom role to `Finance-Team`
- [`check-group-roles.ps1`](./check-group-roles.ps1) — verifies the role assignments on a group
- [`configure-mfa.ps1`](./configure-mfa.ps1) — registers an SMS authentication method for each `HR-Team` member
- [`create-ca-policy1-require-mfa.ps1`](./create-ca-policy1-require-mfa.ps1) — Conditional Access: require MFA (report-only)
- [`create-ca-policy2-block-outside-canada.ps1`](./create-ca-policy2-block-outside-canada.ps1) — Conditional Access: block sign-in from outside Canada via a named location (report-only)
- [`create-ca-policy3-compliant-device-finance.ps1`](./create-ca-policy3-compliant-device-finance.ps1) — Conditional Access: require a compliant device for `Finance-Team` (report-only)

The first two Conditional Access scripts take a mandatory `-ExcludeAdminUPN` parameter, the admin account exempted from the policy.

## Status

✅ Complete
