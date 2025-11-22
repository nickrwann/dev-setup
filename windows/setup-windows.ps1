# Bootstrap core Windows tools. VS Code extensions are installed from the WSL side.
winget install --id Microsoft.WindowsTerminal -e --source winget
winget install --id Microsoft.VisualStudioCode -e --source winget
winget install --id Git.Git -e --source winget --scope machine
winget install --id GitHub.GitHubDesktop -e --source winget
winget install --id Docker.DockerDesktop -e --source winget
winget install --id Spotify.Spotify -e --source winget

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
