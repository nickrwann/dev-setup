# Bootstrap core Windows tools. VS Code extensions are installed from the WSL side.

# --- Configuration -----------------------------------------------------------
$pendingRebootReasons = @()
$resumeMarkerPath = Join-Path $env:ProgramData "dev-setup\resume-setup-windows.txt"

# --- Pending reboot detection -----------------------------------------------
function Add-PendingRebootReason {
    param([string]$Reason)
    if (-not [string]::IsNullOrWhiteSpace($Reason)) { $script:pendingRebootReasons += $Reason }
}

function Note-DismRestartRequirement {
    param([int]$ExitCode, [string]$Context)
    if ($ExitCode -in 3010, 1641) { Add-PendingRebootReason("$Context reported restart required (exit code $ExitCode).") }
}

function Note-RegistryPendingRenames {
    $key = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue
    if ($null -ne $key -and $null -ne $key.PendingFileRenameOperations -and $key.PendingFileRenameOperations.Count -gt 0) {
        Add-PendingRebootReason('Pending file rename operations detected in the registry.')
    }
}

# --- Reboot handling ---------------------------------------------------------
function Save-ResumeMarker {
    param([string]$Reason)
    $markerDirectory = Split-Path $resumeMarkerPath -Parent
    if (-not (Test-Path $markerDirectory)) { New-Item -ItemType Directory -Path $markerDirectory -Force | Out-Null }

    @(
        'Resume setup-windows.ps1 after reboot',
        "Reason: $Reason",
        "Timestamp: $(Get-Date -Format 's')",
        "ScriptPath: $PSCommandPath"
    ) | Set-Content -Path $resumeMarkerPath -Encoding UTF8
    Write-Host "Saved resume marker to $resumeMarkerPath"
}

function Handle-PendingReboot {
    if ($pendingRebootReasons.Count -eq 0) { return }

    Write-Host "A system reboot is required before Ubuntu/WSL can be used:" -ForegroundColor Yellow
    $pendingRebootReasons | ForEach-Object { Write-Host " - $_" -ForegroundColor Yellow }

    if ((Read-Host 'Reboot now? (Y/N)') -match '^[Yy]') {
        Save-ResumeMarker -Reason 'Pending reboot detected after setup-windows.ps1'
        Write-Host 'Initiating reboot...' -ForegroundColor Cyan
        Restart-Computer -Force
        return
    }

    Write-Warning 'Ubuntu/WSL will not be usable until after a reboot.'
    Write-Host "After restarting, re-run setup-windows.ps1 to resume. If a resume marker was created, it is stored at $resumeMarkerPath." -ForegroundColor Cyan
}

# --- Install core tools ------------------------------------------------------
Write-Host 'Installing core Windows tools via winget...'
winget install --id Microsoft.WindowsTerminal -e --source winget
winget install --id Microsoft.VisualStudioCode -e --source winget
winget install --id Git.Git -e --source winget --scope machine
winget install --id GitHub.GitHubDesktop -e --source winget
winget install --id Docker.DockerDesktop -e --source winget
winget install --id Spotify.Spotify -e --source winget

# --- Install WSL and detect reboot need -------------------------------------
Write-Host 'Installing WSL with Ubuntu 22.04...'
function Write-WslUpdateGuidance {
    param([string]$Output)

    if ($Output -match "administrator" -or $Output -match "elevated") {
        Write-Warning "WSL updates require an elevated PowerShell session. Re-run this script as Administrator or run 'wsl --update' from an elevated prompt."
    }
    if ($Output -match "feature" -and ($Output -match "Virtual Machine Platform" -or $Output -match "Windows Subsystem for Linux" -or $Output -match "optional component")) {
        Write-Warning "Required Windows features for WSL are not enabled yet. Run 'wsl --install' from an elevated prompt to enable them, reboot if prompted, then re-run this script."
    }
}

function Invoke-WslUpdate {
    Write-Host "Updating WSL..."
    $updateOutput = & wsl --update 2>&1
    $exitCode = $LASTEXITCODE

    if ($updateOutput) {
        Write-Host $updateOutput
    }

    if ($exitCode -ne 0) {
        Write-Warning "WSL update failed with exit code $exitCode."
        Write-WslUpdateGuidance -Output ($updateOutput -join "`n")
    }
}

Invoke-WslUpdate

Write-Host "Installing WSL distro: Ubuntu-22.04"
wsl --install -d Ubuntu-22.04
Note-DismRestartRequirement -ExitCode $LASTEXITCODE -Context 'WSL install'
Note-RegistryPendingRenames

# --- Prompt for reboot -------------------------------------------------------
Handle-PendingReboot

# --- Stage repo into WSL and run WSL setup ----------------------------------
if ($pendingRebootReasons.Count -eq 0) {
    $repoRoot = (Get-Item $PSScriptRoot).Parent.FullName
    $wslRepoPath = (& wsl -- wslpath -a "$repoRoot").Trim()

    Write-Host "Copying dev-setup into WSL home..."
    wsl -- bash -lc "mkdir -p ~/src/github.com/nickrwann && cp -r '$wslRepoPath' ~/src/github.com/nickrwann/"

    Write-Host "Running WSL bootstrap script..."
    wsl -- bash -lc "bash ~/src/github.com/nickrwann/dev-setup/wsl/setup-wsl.sh"
} else {
    Write-Warning 'Skipping WSL repo copy and bootstrap until after reboot.'
}
