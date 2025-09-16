cd "%~dp0"
pnputil.exe /add-driver "%~dp0WLAN\*.inf" /install
timeout 3
pnputil.exe /add-driver "%~dp0BT\*.inf" /install
timeout 3