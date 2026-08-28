# Gemini Chrome Launcher - 创建桌面快捷方式（可选，替代 .cmd）
# 用法：右键"以 PowerShell 运行"，或在 PowerShell 中执行：
#   powershell -ExecutionPolicy Bypass -File install-shortcut.ps1

$Chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
if (-not (Test-Path $Chrome)) {
    $Chrome = "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
}
if (-not (Test-Path $Chrome)) {
    Write-Host "[错误] 未找到 Chrome" -ForegroundColor Red
    exit 1
}

$Args = "--lang=en-US --variations-override-country=us --enable-features=Glic,GlicSidePanel,GlicButton,GlicWarming,GlicZeroStateSuggestions"

$WshShell = New-Object -ComObject WScript.Shell
$Desktop = [Environment]::GetFolderPath("Desktop")
$Shortcut = $WshShell.CreateShortcut("$Desktop\Gemini Chrome.lnk")
$Shortcut.TargetPath = $Chrome
$Shortcut.Arguments = $Args
$Shortcut.IconLocation = "$Chrome,0"
$Shortcut.Description = "以 Gemini 参数启动 Chrome（需先完全退出已运行的 Chrome）"
$Shortcut.Save()

Write-Host "[完成] 桌面快捷方式已创建：Gemini Chrome.lnk" -ForegroundColor Green
Write-Host "[提示] 若 Chrome 已在运行，快捷方式不会生效，请先完全退出 Chrome。" -ForegroundColor Yellow
