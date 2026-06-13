# Modern local PowerShell profile.
# This profile avoids external dependencies so it works on a clean Windows install.

$script:TermEsc = [char]27
$script:TermColors = @{
    Reset   = "$script:TermEsc[0m"
    Dim     = "$script:TermEsc[2m"
    Bold    = "$script:TermEsc[1m"
    Red     = "$script:TermEsc[38;2;251;113;133m"
    Orange  = "$script:TermEsc[38;2;251;146;60m"
    Yellow  = "$script:TermEsc[38;2;250;204;21m"
    Green   = "$script:TermEsc[38;2;74;222;128m"
    Teal    = "$script:TermEsc[38;2;45;212;191m"
    Cyan    = "$script:TermEsc[38;2;125;211;252m"
    Blue    = "$script:TermEsc[38;2;96;165;250m"
    Purple  = "$script:TermEsc[38;2;196;181;253m"
    Pink    = "$script:TermEsc[38;2;244;114;182m"
    Muted   = "$script:TermEsc[38;2;148;163;184m"
}

function Get-TerminalShortPath {
    $path = (Get-Location).Path
    $homePath = [Environment]::GetFolderPath('UserProfile')

    if ($path.StartsWith($homePath, [StringComparison]::OrdinalIgnoreCase)) {
        $path = '~' + $path.Substring($homePath.Length)
    }

    if ($path.Length -gt 58) {
        $path = '...' + $path.Substring($path.Length - 55)
    }

    return $path
}

function Get-TerminalGitSegment {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        return ''
    }

    $branch = git branch --show-current 2>$null
    if ([string]::IsNullOrWhiteSpace($branch)) {
        $branch = git rev-parse --short HEAD 2>$null
    }

    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($branch)) {
        return ''
    }

    return " $($script:TermColors.Muted)git:$($script:TermColors.Purple)$($branch.Trim())$($script:TermColors.Reset)"
}

function prompt {
    $success = $?
    $lastExitCode = $global:LASTEXITCODE
    $path = Get-TerminalShortPath
    $git = Get-TerminalGitSegment
    $global:LASTEXITCODE = $lastExitCode
    $time = Get-Date -Format 'HH:mm'
    $status = if ($success) {
        "$($script:TermColors.Green)OK$($script:TermColors.Reset)"
    }
    else {
        $code = if ($lastExitCode) { $lastExitCode } else { 'ERR' }
        "$($script:TermColors.Red)$code$($script:TermColors.Reset)"
    }

    try {
        $Host.UI.RawUI.WindowTitle = "PowerShell - $path"
    }
    catch {}

    $line1 = "$($script:TermColors.Cyan)$path$($script:TermColors.Reset)$git $($script:TermColors.Muted)[$time]$($script:TermColors.Reset) $status"
    $line2 = "$($script:TermColors.Pink)PS$($script:TermColors.Reset) $($script:TermColors.Blue)>$($script:TermColors.Reset) "
    return "`n$line1`n$line2"
}

function ll {
    Get-ChildItem -Force @args
}

function la {
    Get-ChildItem -Force @args | Format-Table -AutoSize
}

function which {
    param([Parameter(Mandatory = $true)][string]$Name)
    Get-Command $Name | Select-Object -ExpandProperty Source
}

function touch {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (Test-Path -LiteralPath $Path) {
        (Get-Item -LiteralPath $Path).LastWriteTime = Get-Date
        return
    }
    New-Item -ItemType File -Path $Path | Out-Null
}

function mkcd {
    param([Parameter(Mandatory = $true)][string]$Path)
    New-Item -ItemType Directory -Force -Path $Path | Out-Null
    Set-Location -LiteralPath $Path
}

try {
    Import-Module PSReadLine -ErrorAction SilentlyContinue
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -HistoryNoDuplicates
    Set-PSReadLineOption -BellStyle None
    Set-PSReadLineOption -Colors @{
        Command   = "$script:TermEsc[38;2;125;211;252m"
        Parameter = "$script:TermEsc[38;2;196;181;253m"
        String    = "$script:TermEsc[38;2;134;239;172m"
        Operator  = "$script:TermEsc[38;2;251;113;133m"
        Variable  = "$script:TermEsc[38;2;253;224;71m"
        Number    = "$script:TermEsc[38;2;251;146;60m"
        Type      = "$script:TermEsc[38;2;45;212;191m"
        Comment   = "$script:TermEsc[38;2;100;116;139m"
    }

    $psReadLineParams = (Get-Command Set-PSReadLineOption).Parameters
    if ($psReadLineParams.ContainsKey('PredictionSource')) {
        Set-PSReadLineOption -PredictionSource History
    }
    if ($psReadLineParams.ContainsKey('PredictionViewStyle')) {
        Set-PSReadLineOption -PredictionViewStyle ListView
    }

    Set-PSReadLineKeyHandler -Key Ctrl+Spacebar -Function MenuComplete
    Set-PSReadLineKeyHandler -Key Ctrl+Backspace -Function BackwardDeleteWord
}
catch {}

if (-not $env:CODEX_TERMINAL_PROFILE_LOADED) {
    $env:CODEX_TERMINAL_PROFILE_LOADED = '1'
    Write-Host ''
    Write-Host '  PEDRE TERMINAL' -ForegroundColor Cyan
    Write-Host '  Modern PowerShell profile loaded' -ForegroundColor DarkGray
}
