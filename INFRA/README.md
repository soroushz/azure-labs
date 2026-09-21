# 🏗️ INFRA — Azure Infrastructure Deployment

`Azure Networking` `VNet & Subnets` `PowerShell` `Az Module` `NSGs` `Virtual Machines`

Real Azure infrastructure — networking, virtual machines, and network security — the foundational skills every Azure admin needs day to day. Built in a lab environment and automated end-to-end with PowerShell (Az module).

## What's covered

- **Networking** — a Virtual Network (`10.0.0.0/16`) with two subnets, `WebSubnet` (`10.0.1.0/24`) and `DBSubnet` (`10.0.2.0/24`), built with a reusable, idempotent PowerShell script (safe to re-run).
- **Virtual Machines** — a Windows Server 2022 VM in `WebSubnet` and an Ubuntu 22.04 VM in `DBSubnet`, deployed from a data-driven script (add a VM by adding an array entry, not new logic).
- **Network Security Groups** — `WebVM-nsg` allows HTTP/HTTPS from the internet; `DBVM-nsg` only allows SQL (1433) in from `WebSubnet`, with an explicit deny-all-other-internet-inbound rule, closing the SSH-to-internet gap `-OpenPorts` leaves by default on VM creation.

## NSG Rules Summary

| NSG | Rule | Port | Source | Action | Why |
|---|---|---|---|---|---|
| WebVM-nsg | Allow-HTTP | 80 | Internet | Allow | Public web traffic needs to reach the app |
| WebVM-nsg | Allow-HTTPS | 443 | Internet | Allow | Same, encrypted |
| DBVM-nsg | Allow-SQL-From-Web | 1433 | WebSubnet (10.0.1.0/24) | Allow | Only the app tier should ever query the database |
| DBVM-nsg | Deny-Internet-Inbound | All | Internet | Deny | Database should never be reachable from the public internet directly |

## Scripts

_Coming soon — scripts pending upload._

## Status

🟡 In Progress
