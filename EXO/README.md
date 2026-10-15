# 📧 EXO — Exchange Online Administration

`Exchange Online` `PowerShell` `Certificate-Based Auth`

Mailbox and mail-flow administration in Exchange Online, using certificate-based app-only authentication so every script runs unattended — no interactive sign-in. Built in a lab environment and automated end-to-end with PowerShell.

## What's covered

- **Connect & Prerequisites** — a self-signed certificate, an Entra ID app registration assigned the Exchange Administrator role via Microsoft Graph, and the `Exchange.ManageAsApp` permission for cert-based Exchange Online auth.
- **Shared Mailboxes** — created with Full Access and Send As permissions granted separately (Exchange treats them as two independent permissions).
- **Distribution Groups** — mail-only groups with array-driven member lists.
- **Mail Flow Rules** — a rule blocking "password" in email subjects, and an auto-disclaimer rule appended to outbound mail.

## Scripts

- [`create-exo-certificate.ps1`](./create-exo-certificate.ps1) — self-signed cert for app-only auth
- [`assign-exo-role.ps1`](./assign-exo-role.ps1) — Exchange Administrator role via Graph
- [`connect-exo.ps1`](./connect-exo.ps1) — cert-based Connect-ExchangeOnline session
- [`create-shared-mailboxes.ps1`](./create-shared-mailboxes.ps1) — shared mailboxes + Full Access/Send As
- [`create-distribution-groups.ps1`](./create-distribution-groups.ps1) — distribution groups + members
- [`create-mail-flow-rules.ps1`](./create-mail-flow-rules.ps1) — password-block + disclaimer transport rules

_Placeholder files pending your real script content — see each file for what to paste in._

## Status

✅ Complete
