# 🔐 AID — Azure Identity & Access Management

`Entra ID` `RBAC` `PowerShell` `Microsoft Graph API` `MFA` `Conditional Access` `Least Privilege`

A complete identity and access management setup in Microsoft Azure — the most critical skill for any Azure administrator. Built in a dedicated lab environment, isolated from any work/school account, and automated with PowerShell and the Microsoft Graph API.

## What's covered

- **Users & Groups** — test users provisioned per department (IT, HR, Finance) via `Invoke-MgGraphRequest` against the Graph API, plus security groups and bulk group assignment, all scripted instead of clicked through the portal.
- **RBAC Roles** — built-in role assignment, a custom role definition, and custom role assignment, with before/after verification that access is actually restricted as expected.
- **MFA Configuration** — authentication method policies applied per team (HR), with a live authentication test.
- **Conditional Access Policies** — three policies: require MFA for all users, block sign-in from outside Canada (named location), and require a compliant device for the Finance team.

## Scripts

_Coming soon — scripts pending upload._

## Status

✅ Complete
