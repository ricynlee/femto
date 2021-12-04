@echo off
set /p = Cleaning workspace... <nul

rd /s /q  %~dp0project\.Xil                 2>nul
rd /s /q  %~dp0project\femto.cache          2>nul
rd /s /q  %~dp0project\femto.hw             2>nul
rd /s /q  %~dp0project\femto.ip_user_files  2>nul
rd /s /q  %~dp0project\femto.runs           2>nul
rd /s /q  %~dp0project\femto.sim            2>nul
del /f /q %~dp0project\*.jou                2>nul
del /f /q %~dp0project\*.log                2>nul
del /f /q %~dp0project\*.str                2>nul

del /f /q %~dp0src\out.*                    2>nul
del /f /q %~dp0src\*.hex                    2>nul
del /f /q %~dp0src\*.bin                    2>nul
del /f /q %~dp0src\nor.h                    2>nul

echo Done
pause
