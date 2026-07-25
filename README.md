# Valheim Dedicated Server Setup Guide

Complete end-to-end setup for a Windows Valheim dedicated server with Tailscale.

---

## Prerequisites

- Windows 10 or 11
- Steam account
- Tailscale account + client installed on all machines (server + friends)
- PowerShell access; firewall section MUST be run as Administrator
- Enough disk space for server files + world saves (~a few GB depending on world size)

---

## Step 1 — Install Steam

1. Download Steam: https://store.steampowered.com/about/
2. Run the installer, complete setup, and log into your Steam account.
3. If prompted about Steam Guard, approve it.

---

## Step 2 — Install Valheim

1. In Steam → Store, search for `Valheim`.
2. Click **Add to Cart** and purchase/install.
3. After install, launch Valheim once so it completes first-time setup.
4. Exit Valheim after the main menu appears.
5. If prompted to create a character, you can skip; the dedicated server does not need a character.

---

## Step 3 — Install Valheim Dedicated Server

1. In Steam → Library, click the dropdown next to your account name at top-left.
2. Select **Tools**.
3. Find `Valheim Dedicated Server` in the list.
4. Click **Install**.
5. Default install location:
   `C:\Program Files (x86)\Steam\steamapps\common\Valheim dedicated server`
6. Wait for install to finish; do not launch it yet.

---

## Step 4 — Clone This Repo Into the Server Directory

If you are setting up a different machine than the one that created this repo, copy the latest contents of this repo into:
`C:\Program Files (x86)\Steam\steamapps\common\Valheim dedicated server\`

The easiest way from PowerShell:
```powershell
git clone https://github.com/WickedHaze/valheim-server.git "C:\Program Files (x86)\Steam\steamapps\common\Valheim dedicated server"
```

If you already extracted/copied the files manually, skip clone.

---

## Step 5 — Configure the Server Launcher

Open `start_server.bat` in Notepad and edit the lines near the top if desired:

```
SET SERVERNAME=LegendofRagnamok   ← server name shown in lobby
SET PORT=2456                      ← default game port; keep unless you have a reason
SET WORLD=DediServer1              ← world name; will be created if missing
SET PASSWORD=hitam                 ← 5+ characters, cannot match server name exactly
```

Save the file and leave it in place.

---

## Step 6 — Open Firewall Ports

This MUST be run from an **Administrator** PowerShell window.

1. Search Start for `PowerShell`.
2. Right-click **Windows PowerShell** → **Run as administrator**.
3. Paste the following and press Enter:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\setup_firewall.ps1
```

If it outputs `Valheim firewall rules applied.`, the rules are live.

What these rules do:
- Allow incoming UDP `2456` and `2457`
- Allow incoming TCP `2458`
- Apply to all Windows Firewall profiles, including Tailscale

---

## Step 7 — Ensure Tailscale Is Ready

1. Install Tailscale: https://tailscale.com/download
2. Log into the same Tailscale network as your friends.
3. Verify connectivity:
```powershell
"C:\Program Files\Tailscale\tailscale.exe" ip
```
It should print a `100.x.x.x` address. That is the address friends will use.

---

## Step 8 — Run the Server

1. **Log out of the Steam client completely.**
   - The dedicated server must not share the same Steam session as a running Valheim client.
   - If you want Steam open for other things, use a different Steam account for the client, or run the server and client on different machines.

2. Double-click `start_server.bat`.

3. A command window will open. Let it run. You should see lines such as:
   - `Steam game server initialized`
   - `PlayFab logged in as ...`
   - `Game server connected`
   - `Session "..." registered with join code ...`

4. **Leave the window open.** Closing it stops the server.

---

## Step 9 — Have Friends Join

Your Tailscale IP from Step 7 is the join address.

Example:
```
100.111.140.2:2456
```

How to join in Valheim:
1. Click **Start Game** → **Join Game**.
2. Click **IP**.
3. Paste `100.111.140.2:2456`.
4. Enter the server password from Step 5.

If the server does not appear in the public server browser, that is expected if you use direct connect with the Tailscale IP.

---

## Important Notes

### Public IP in logs / server browser
Valheim auto-detects your outward-facing public IP when registering with PlayFab/Steam and may advertise that IP in logs and server listings.

This does not necessarily mean your friends will route through the public internet:
- Over Tailscale, traffic between two nodes is mesh-routed.
- If direct connection via Tailscale IP works, the advertised public IP is only cosmetic.

### Server quits after about a minute
This happens when Steam is logged in with the same account as the server session. Fix:
- Log out of Steam entirely, then restart the `.bat`.
- Or run the server on a different machine from the Steam client.

### Ports
Default ports used by Valheim Dedicated Server:
- UDP `2456` — game traffic
- UDP `2457` — query traffic
- TCP `2458` — Steam master server / query traffic

Only `2456` is required for basic gameplay; `2457` and `2458` help with server browser visibility and querying.

### World save location
World files are stored under the **server machine's** Windows user:
```
C:\Users\<SERVER_USER>\AppData\LocalLow\IronGate\Valheim\worlds_local\<WORLD_NAME>.db
```

If you change Windows users after creating a world, copy `worlds_local` to the new user profile.

---

## Troubleshooting

### Window closes immediately when I double-click start_server.bat
- Open Command Prompt manually and run:
  ```
  "C:\Program Files (x86)\Steam\steamapps\common\Valheim dedicated server\start_server.bat"
  ```
- Read the last few lines and share them if it errors.

### Friends cannot join via Tailscale IP
- Confirm `setup_firewall.ps1` actually completed without errors in Administrator PowerShell.
- Confirm Tailscale is connected on both machines.
- Confirm you used `10100.x` or `100.x.x.x` (Tailscale IP), not the public IP.
- Run this and look for `0.0.0.0:2457` on the server machine:
  ```powershell
  Get-NetUDPEndpoint | ? { $_.LocalPort -eq 2456 -or $_.LocalPort -eq 2457 } | ft LocalAddress,LocalPort
  ```

### World not found
- Check `C:\Users\<SERVER_USER>\AppData\LocalLow\IronGate\Valheim\worlds_local\`
- Make sure `WORLD=` in `start_server.bat` matches the `.db` filename stem.

### Server not visible in public browser
That is normal when using only Tailscale direct connect. It does not affect joining.

---

## Repository Files

| File | Purpose |
|------|---------|
| `start_server.bat` | Main launcher, edit settings at the top |
| `setup_firewall.ps1` | Must run in Administrator PowerShell to open ports |
| `README.md` | Short reference back to this guide |
| `.gitignore` | Skips log and dump files |

---

## Quick Copy for Another Machine

```powershell
git clone https://github.com/WickedHaze/valheim-server.git "C:\Program Files (x86)\Steam\steamapps\common\Valheim dedicated server"
```

Then follow Steps 5, 6, and 8 above.
