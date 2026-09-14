@echo off
setlocal
title Gemini Chrome Launcher (Windows)

REM ============================================================
REM  This file is ASCII-only on purpose. Do NOT add non-ASCII
REM  characters.
REM
REM  cmd.exe parses batch files byte by byte using the current OEM
REM  code page. Non-ASCII bytes inside a .cmd can be decoded into
REM  metacharacters (| & > <) which split the line, and the launch
REM  command gets silently skipped.
REM  The previous Gemini-Setup-Win.bat in the sibling repository
REM  failed for exactly this reason: its Chinese text broke the
REM  parser and the python call never ran.
REM
REM  No --lang is passed on purpose. Glic availability is
REM  independent of the UI language (verified: --lang=zh-CN works
REM  exactly the same as --lang=en-US), so Chrome keeps whatever
REM  language the profile is already using.
REM ============================================================

echo ============================================
echo    Gemini Chrome Launcher (Windows)
echo ============================================
echo.

set "CHROME=C:\Program Files\Google\Chrome\Application\chrome.exe"
if not exist "%CHROME%" set "CHROME=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"
if not exist "%CHROME%" (
    echo [ERROR] Chrome not found. Check your installation path.
    pause
    exit /b 1
)

rem Launch flags only take effect on a brand-new browser process.
tasklist /FI "IMAGENAME eq chrome.exe" 2>nul | find /I "chrome.exe" >nul
if %errorlevel%==0 (
    echo [STOP] Chrome is already running.
    echo        Launch flags are ignored by an existing process.
    echo        Quit Chrome completely first ^(tray icon - Exit^),
    echo        then run this script again.
    echo.
    pause
    exit /b 1
)

echo [RUN] Starting Chrome with the Gemini feature flags...
start "" "%CHROME%" --variations-override-country=us --enable-features=Glic,GlicSidePanel,GlicButton,GlicWarming,GlicZeroStateSuggestions
echo [OK] Chrome started.
echo.
pause
