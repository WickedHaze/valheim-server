# Valheim Dedicated Server Setup

Headless Valheim Dedicated Server launcher + firewall setup for Windows + Tailscale.

## Prerequisites

- Steam + Valheim installed on the same machine
- `Valheim Dedicated Server` tool installed via Steam
- Tailscale installed and connected
- PowerShell running as **Administrator** for firewall rules

## Setup

1. Clone this repo somewhere stable, e.g.:
```powershell
git clone https://github.com/WickedHaze/valheim-server.git "C:\Program Files (x86)\Steam\steamapps\common\Valheim dedicated server"
```

2. Edit `start_server.bat` if needed:
- `SERVERNAME=` — server lobby name
- `WORLD=` — world name
- `PASSWORD=` — must be 5+ chars, can't match server name exactly

3. Apply firewall rules (Admin PowerShell required):
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\setup_firewall.ps1
```

If you get Access Denied, right-click PowerShell → Run as Administrator, then retry.

## Running

Run `start_server.bat`. Keep the window open; closing it stops the server.

## Joining

Friends use your **Tailscale IP** (from `tailscale ip`) on port `2456`.

Example: `100.111.140.2:2456`

Note: the server will still advertise your public IP in logs/PlayFab registration. That does not affect joining directly via Tailscale once firewall rules are in place.

## Troubleshooting

- Server quits after ~60s: you are likely logged into Steam with the same account. Log out fully and retry.
- Tailscale join fails: make sure `setup_firewall.ps1` actually ran in elevated PowerShell and didn't error out.
- Port check: `Get-NetUDPEndpoint | ? { $_.LocalPort -eq 2456 -or $_.LocalPort -eq 2457 }`
