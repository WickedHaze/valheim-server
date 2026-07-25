@echo off
set SteamAppId=892970

REM ------------------ EDIT THESE ------------------
SET SERVERNAME=LegendofRagnamok
SET PORT=2456
SET WORLD=DediServer1
SET PASSWORD=hitam
REM ------------------------------------------------

echo Starting Valheim dedicated server...
echo Name   : %SERVERNAME%
echo Port   : %PORT%
echo World  : %WORLD%
echo Press Ctrl+C to stop.

REM Run from the same directory as this script.
cd /d "%~dp0"
valheim_server -nographics -batchmode -name "%SERVERNAME%" -port %PORT% -world "%WORLD%" -password "%PASSWORD%" -crossplay

pause
