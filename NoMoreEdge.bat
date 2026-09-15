@echo off
setlocal EnableDelayedExpansion
title Remove Microsoft Edge Completely

:: Must run as Admin
net session >nul 2>&1
if %errorLevel% neq 0 (
  echo ERROR: Right-click this file ^> Run as administrator.
  pause
  exit /b 1
)

echo [1/5] Killing Edge processes...
taskkill /F /IM msedge.exe /T 2>nul
taskkill /F /IM msedgewebview2.exe /T 2>nul
taskkill /F /IM msedge_proxy.exe /T 2>nul
taskkill /F /IM pwahelper.exe /T 2>nul
taskkill /F /IM edgeupdate.exe /T 2>nul
taskkill /F /IM MicrosoftEdgeUpdate.exe /T 2>nul

echo [2/5] Uninstalling Edge...
for /d %%i in ("C:\Program Files (x86)\Microsoft\Edge\Application\*") do (
  if exist "%%i\Installer\setup.exe" (
    echo Found %%i
    "%%i\Installer\setup.exe" --uninstall --system-level --verbose-logging --force-uninstall
  )
)
for /d %%i in ("C:\Program Files\Microsoft\Edge\Application\*") do (
  if exist "%%i\Installer\setup.exe" (
    echo Found %%i
    "%%i\Installer\setup.exe" --uninstall --system-level --verbose-logging --force-uninstall
  )
)
timeout /t 5 /nobreak >nul

echo [3/5] Removing services and tasks...
sc stop edgeupdate 2>nul
sc stop edgeupdatem 2>nul
sc stop MicrosoftEdgeElevationService 2>nul
sc delete edgeupdate 2>nul
sc delete edgeupdatem 2>nul
sc delete MicrosoftEdgeElevationService 2>nul

for /f "tokens=1 delims=," %%a in ('schtasks /query /fo csv ^| findstr /i "Edge"') do (
  set "t=%%a"
  set "t=!t:"=!"
  echo Deleting task !t!
  schtasks /delete /tn "!t!" /f 2>nul
)

echo [4/5] Deleting files...
rmdir /s /q "C:\Program Files (x86)\Microsoft\Edge" 2>nul
rmdir /s /q "C:\Program Files (x86)\Microsoft\EdgeCore" 2>nul
rmdir /s /q "C:\Program Files (x86)\Microsoft\EdgeUpdate" 2>nul
rmdir /s /q "%LOCALAPPDATA%\Microsoft\Edge" 2>nul
rmdir /s /q "%LOCALAPPDATA%\Microsoft\EdgeUpdate" 2>nul
rmdir /s /q "%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs\Microsoft Edge" 2>nul
del /f /q "%USERPROFILE%\Desktop\Microsoft Edge.lnk" 2>nul
del /f /q "%PUBLIC%\Desktop\Microsoft Edge.lnk" 2>nul
del /f /q "%APPDATA%\Microsoft\Internet Explorer\Quick Launch\Microsoft Edge.lnk" 2>nul

:: NOTE: EdgeWebView left intact on purpose. Delete it only if you don't use Teams/Office/etc.
:: rmdir /s /q "C:\Program Files (x86)\Microsoft\EdgeWebView" 2>nul

echo [5/5] Blocking auto-reinstall...
reg add "HKLM\SOFTWARE\Microsoft\EdgeUpdate" /v DoNotUpdateToEdgeWithChromium /t REG_DWORD /d 1 /f

echo.
echo --- VERIFY ---
if exist "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" (echo STILL EXISTS) else (echo EDGE GONE)
where msedge 2>nul
if %errorLevel% equ 0 (echo msedge still in PATH) else (echo msedge not found - good)
echo.
echo Done. Reboot recommended. Set another default browser in Settings ^> Apps ^> Default apps.
pause
