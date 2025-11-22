# Bootstraps core Windows tools and installs WSL/Ubuntu 22.04.
# Run this in an elevated PowerShell session first on a new machine.

# Verify script is running as Administrator so winget and WSL can change system state.
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Error "Please run this script in an elevated PowerShell session (Run as Administrator)."
    exit 1
}

Write-Host "Installing core Windows tools via winget..." -ForegroundColor Cyan

# Core terminal and editor.
winget install --id Microsoft.WindowsTerminal -e --source winget
winget install --id Microsoft.VisualStudioCode -e --source winget

# Git tooling.
winget install --id Git.Git -e --source winget --scope machine
winget install --id GitHub.GitHubDesktop -e --source winget

# Docker for local Kubernetes and containers.
winget install --id Docker.DockerDesktop -e --source winget

# Optional quality of life app.
winget install --id Spotify.Spotify -e --source winget

# Note: "tree" is already available on Windows via the built-in tree.exe command.

Write-Host ""
Write-Host "Updating WSL (if present)..." -ForegroundColor Cyan

try {
    # Update WSL components if they are already installed.
    & wsl --update
} catch {
    # On a fresh machine this may fail before WSL is installed. That is fine.
    Write-Warning "WSL update failed or WSL is not installed yet. Continuing."
}

Write-Host ""
Write-Host "Installing WSL with Ubuntu 22.04..." -ForegroundColor Cyan

$exitCode = 0
try {
    # Install default WSL features plus the Ubuntu 22.04 distro.
    & wsl --install -d Ubuntu-22.04
    $exitCode = $LASTEXITCODE
} catch {
    Write-Warning "WSL install command failed: $($_.Exception.Message)"
    $exitCode = 1
}

Write-Host ""

if ($exitCode -eq 0) {
    # Typical case once WSL and Ubuntu are installed.
    Write-Host "WSL install command completed. If Windows requested a reboot, reboot now." -ForegroundColor Green
} else 
    # On first install, nonzero often means features were enabled and a reboot is pending.
    Write-Warning "WSL install reported a nonzero exit code ($exitCode)."
    Write-Host "On a fresh machine this usually means Windows needs a reboot to finish enabling WSL features." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Reboot Windows if you were prompted to do so."
Write-Host "  2. Open Ubuntu 22.04 from the Start menu once and complete its first-time setup."
Write-Host "  3. Then run: dev-setup\\windows\\setup-wsl.ps1"
