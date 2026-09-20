@echo off
chcp 65001 >nul
REM 双击运行：调用 PowerShell 执行服务器代码打包（不打包资源）
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0package.ps1"
echo.
pause
