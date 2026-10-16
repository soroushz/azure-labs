# 🔐 AID — Azure Identity & Access Management

`Entra ID` `RBAC` `PowerShell` `Microsoft Graph API` `MFA` `Conditional Access` `Least Privilege`

A complete identity and access management setup in Microsoft Azure — the most critical skill for any Azure administrator. Built in a dedicated lab environment, isolated from any work/school account, and automated with PowerShell and the Microsoft Graph API.

## What's covered

- **Users & Groups** — test users provisioned per department (IT, HR, Finance) via `Invoke-MgGraphRequest` against the Graph API, plus security groups and bulk group assignment, all scripted instead of clicked through the portal.
- **RBAC Roles** — built-in role assignment, a custom role definition, and custom role assignment, with before/after verification that access is actually restricted as expected.
- **MFA Configuration** — authentication method policies applied per team (HR), with a live authentication test.
- **Conditional Access Policies** — three policies: require MFA for all users, block sign-in from outside Canada (named location), and require a compliant device for the Finance team.

## Scripts

- [`create-aid-users.ps1`](./create-aid-users.ps1) — creates the 3 departmental test users
- [`create-aid-security-groups.ps1`](./create-aid-security-groups.ps1) — creates the 3 security groups
- [`assign-aid-group-members.ps1`](./assign-aid-group-members.ps1) — maps users to their group
- [`assign-aid-rbac-roles.ps1`](./assign-aid-rbac-roles.ps1) — built-in + custom RBAC role assignment
- [`configure-aid-mfa.ps1`](./configure-aid-mfa.ps1) — registers HR-Team for SMS MFA
- [`create-aid-conditional-access.ps1`](./create-aid-conditional-access.ps1) — the 3 Conditional Access policies

## Status

✅ Complete
