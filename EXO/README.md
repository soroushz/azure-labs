# 📧 EXO — Exchange Online Administration

`Exchange Online` `PowerShell` `Certificate-Based Auth`

Mailbox and mail-flow administration in Exchange Online, using certificate-based app-only authentication so every script runs unattended — no interactive sign-in. Built in a lab environment and automated end-to-end with PowerShell.

## What's covered

- **Connect & Prerequisites** — a self-signed certificate, an Entra ID app registration assigned the Exchange Administrator role via Microsoft Graph, and the `Exchange.ManageAsApp` permission for cert-based Exchange Online auth.
- **Shared Mailboxes** — created with Full Access and Send As permissions granted separately (Exchange treats them as two independent permissions).
- **Distribution Groups** — mail-only groups with array-driven member lists.
- **Mail Flow Rules** — a rule blocking "password" in email subjects, and an auto-disclaimer rule appended to outbound mail.

## Scripts

Tenant-specific values are placeholders: pass your own `-AppId`, `-CertThumbprint` and `-Organization` to `connect-exo.ps1`, and replace `contoso.onmicrosoft.com` in the mailbox and group addresses with your tenant domain.

- [`create-exo-certificate.ps1`](./create-exo-certificate.ps1) — creates a self-signed certificate and exports its public key for the app registration
- [`assign-exo-role.ps1`](./assign-exo-role.ps1) — assigns the Exchange Administrator role to the app's service principal via Microsoft Graph
- [`connect-exo.ps1`](./connect-exo.ps1) — opens a certificate-based, app-only Exchange Online session
- [`create-shared-mailboxes.ps1`](./create-shared-mailboxes.ps1) — creates shared mailboxes and grants Full Access and Send As separately
- [`create-distribution-groups.ps1`](./create-distribution-groups.ps1) — creates distribution groups and adds their members
- [`create-mail-flow-rules.ps1`](./create-mail-flow-rules.ps1) — creates the password-in-subject block rule and the outbound disclaimer rule

## Status

✅ Complete
