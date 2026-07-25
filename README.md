# Valheim Dedicated Server Setup Guide

Complete end-to-end setup for a Windows Valheim dedicated server reachable via public IP.

---

## Prerequisites

- Windows 10 or 11
- Steam account
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
- Apply to all Windows Firewall profiles

---

## Step 7 — Make Sure Inbound Traffic Can Reach the Server

You do **not** always need to change router settings. Valheim/Steam commonly uses Steam Datagram Relay (SDR), which can bridge connections even without open router ports.

Check this first:
- Have a friend try joining via direct connect: `<YOUR_PUBLIC_IP>:2456`
- If that works, nothing else is needed here.

If direct connect fails, try the next steps in order.

### A. Apply Windows Firewall rules
Run `setup_firewall.ps1` from **Administrator PowerShell** as described in Step 6. This only affects this PC; it does not change your router.

### B. Verify router port behavior
If your router supports UPnP, it may already allow the ports automatically. If not, and direct connect still fails, you can optionally add manual forwarding for:
- UDP `2456`
- UDP `2457`
- TCP `2458`

Target your machine’s local IPv4 address if you do.
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

Friends join using your **public IP** and port `2456`.

Example:
```
<YOUR_PUBLIC_IP>:2456
```

How to join in Valheim:
1. Click **Start Game** → **Join Game**.
2. Click **IP**.
3. Paste `<YOUR_PUBLIC_IP>:2456`.
4. Enter the server password from Step 5.

If the server does not appear in the public server browser, direct connect still works. Steam Datagram Relay may also help connect players when direct routing is restricted.

---

## Important Notes

### Public IP in logs / server browser
Valheim auto-detects your outward-facing public IP when registering with PlayFab/Steam and may advertise that IP in logs and server listings. That is normal. Friends should join with that public IP:port, but Steam Datagram Relay can still bridge the connection even if routing is restricted.

### Router settings / port forwarding
Manual port forwarding is optional. Direct connect often works without router changes because Steam SDR/relay handles traversal. If joins fail, try `setup_firewall.ps1` first, then consider enabling UPnP or manual forwarding as a last resort.

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
  "C:\Program Files (x86)\teams\steamapps\common\Valheim dedicated server\start_server.bat"
  ```
- Read the last few lines and share them if it errors.

### Friends cannot join
- Confirm `setup_firewall.ps1` actually completed without errors in Administrator PowerShell.
- Confirm this machine has outbound internet; Steam relay needs it to help bridge connections.
- Run this on the server machine to confirm local listening:
  ```powershell
  Get-NetUDPEndpoint | ? { $_.LocalPort -eq 2456 -or $_.LocalPort -eq 2457 } | ft LocalAddress,LocalPort
  ```
- If the server only appears via direct public IP and not Tailscale, that is expected when Steam relay is handling traversal.
- If all else fails, try the same network with all players on Tailscale and direct connect to `100.x.x.x:2456`.

### World not found
- Check `C:\Users\<SERVER_USER>\AppData\LocalLow\IronGate\Valheim\worlds_local\`
- Make sure `WORLD=` in `start_server.bat` matches the `.db` filename stem.

### Server not visible in public browser
That is normal with port forwarding issues or strict NATs. Direct connect still works.

---

## Repository Files

| File | Purpose |
|------|---------|
| `start_server.bat` | Main launcher, edit settings at the top |
| `setup_firewall.ps1` | Must run in Administrator PowerShell to open ports |
| `README.md` | This guide |

---

## Quick Copy for Another Machine

```powershell
git clone https://github.com/WickedHaze/valheim-server.git "C:\Program Files (x86)\Steam\steamapps\common\Valheim dedicated server"
```

Then follow Steps 5, 6, and 8 above.
