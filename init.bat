@echo off
set /p = Initializing workspace... <nul

set hexpath="%~dp0rtl\sim\"
echo `define HEX_PATH %hexpath:\=/% > %~dp0rtl\sim\simpaths.vh

echo Done
pause
