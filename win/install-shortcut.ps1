# Gemini Chrome Launcher - create a desktop shortcut (optional, replaces the .cmd)
# Usage: right-click "Run with PowerShell", or run:
#   powershell -ExecutionPolicy Bypass -File install-shortcut.ps1
#
# ASCII-only on purpose, so the file stays readable regardless of the
# encoding PowerShell happens to assume for the current code page.

$Chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
if (-not (Test-Path $Chrome)) {
    $Chrome = "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
}
if (-not (Test-Path $Chrome)) {
    Write-Host "[ERROR] Chrome not found" -ForegroundColor Red
    exit 1
}

# No --lang on purpose: Glic availability is independent of the UI language,
# so Chrome keeps the language the profile is already using.
$LaunchArgs = "--variations-override-country=us --enable-features=Glic,GlicSidePanel,GlicButton,GlicWarming,GlicZeroStateSuggestions"

$WshShell = New-Object -ComObject WScript.Shell
$Desktop = [Environment]::GetFolderPath("Desktop")
$Shortcut = $WshShell.CreateShortcut("$Desktop\Gemini Chrome.lnk")
$Shortcut.TargetPath = $Chrome
$Shortcut.Arguments = $LaunchArgs
$Shortcut.IconLocation = "$Chrome,0"
$Shortcut.Description = "Launch Chrome with the Gemini (Glic) flags. Quit Chrome completely first."
$Shortcut.Save()

Write-Host "[OK] Desktop shortcut created: Gemini Chrome.lnk" -ForegroundColor Green
Write-Host "[NOTE] If Chrome is already running the shortcut has no effect." -ForegroundColor Yellow
Write-Host "       Quit Chrome completely, then use the shortcut." -ForegroundColor Yellow
