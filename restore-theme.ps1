$ErrorActionPreference = 'Stop'

$sourceDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$profileSource = Join-Path $sourceDir 'Microsoft.PowerShell_profile.ps1'
$terminalSource = Join-Path $sourceDir 'windows-terminal-settings.json'

$profileTarget = Join-Path $HOME 'Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1'
$terminalTarget = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'

if (-not (Test-Path -LiteralPath $profileSource)) {
    throw "Missing source file: $profileSource"
}

if (-not (Test-Path -LiteralPath $terminalSource)) {
    throw "Missing source file: $terminalSource"
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $profileTarget) | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $terminalTarget) | Out-Null

if (Test-Path -LiteralPath $profileTarget) {
    Copy-Item -LiteralPath $profileTarget -Destination "$profileTarget.backup-$timestamp" -Force
}

if (Test-Path -LiteralPath $terminalTarget) {
    Copy-Item -LiteralPath $terminalTarget -Destination "$terminalTarget.backup-$timestamp" -Force
}

Copy-Item -LiteralPath $profileSource -Destination $profileTarget -Force
Copy-Item -LiteralPath $terminalSource -Destination $terminalTarget -Force

Write-Host 'Theme restored. Close and reopen Windows Terminal.' -ForegroundColor Cyan
