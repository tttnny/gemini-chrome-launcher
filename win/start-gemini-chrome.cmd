@echo off
chcp 65001 >nul
title Gemini Chrome 启动器
echo ============================================
echo    Gemini Chrome Launcher (Windows)
echo ============================================
echo.

set "CHROME=C:\Program Files\Google\Chrome\Application\chrome.exe"
if not exist "%CHROME%" set "CHROME=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"
if not exist "%CHROME%" (
    echo [错误] 未找到 Chrome，请检查安装路径。
    pause
    exit /b 1
)

rem 检测 Chrome 是否正在运行（参数只对全新进程生效）
tasklist /FI "IMAGENAME eq chrome.exe" 2>nul | find /I "chrome.exe" >nul
if %errorlevel%==0 (
    echo [提示] Chrome 正在运行。
    echo        请先完全退出 Chrome（托盘图标右键 - 退出），再重新运行本脚本，
    echo        否则启动参数不会生效。
    echo.
    timeout /t 5 >nul
    exit /b 1
)

echo [启动] 正在以 Gemini 参数启动 Chrome...
start "" "%CHROME%" ^
  --lang=en-US ^
  --variations-override-country=us ^
  --enable-features=Glic,GlicSidePanel,GlicButton,GlicWarming,GlicZeroStateSuggestions
echo [完成] Chrome 已启动。如果侧边栏仍不可用，请检查美国住宅 IP。
echo.
pause
