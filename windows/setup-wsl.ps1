# Stages the dev-setup repo into WSL and runs the WSL bootstrap script.
# Run this after setup-windows.ps1, after reboot, and after Ubuntu 22.04 is initialized.

Write-Host "Preparing to stage dev-setup into WSL and run WSL bootstrap..." -ForegroundColor Cyan

# Check that WSL is available at all.
try {
    $wslInfo = & wsl -l -v 2>$null
} catch {
    Write-Error "WSL does not appear to be available. Make sure you ran setup-windows.ps1 and rebooted."
    exit 1
}

if (-not $wslInfo) {
    # WSL installed but no distros listed often means Ubuntu has not been launched once yet.
    Write-Error "WSL returned no distributions. Open Ubuntu from the Start menu at least once, then rerun this script."
    exit 1
}

if ($wslInfo -notmatch "Ubuntu-22.04") {
    # Guard to avoid copying into the wrong distro.
    Write-Warning "Ubuntu-22.04 is not listed among WSL distributions."
    Write-Warning "Make sure Ubuntu 22.04 is installed and initialized, then rerun this script."
    Write-Host $wslInfo
    exit 1
}

# Determine the repo root. Assumes this script lives in dev-setup/windows.
$repoRoot = (Get-Item $PSScriptRoot).Parent.FullName
Write-Host "Detected repo root: $repoRoot"

# Convert the Windows repo path to a WSL path so WSL can see the files.
$wslRepoPath = (& wsl -- wslpath -a "$repoRoot").Trim()
Write-Host "Repo path inside WSL: $wslRepoPath"

# Build the copy command that will run inside WSL.
Write-Host "Copying dev-setup into WSL home..." -ForegroundColor Cyan
$wslCopyCommand = @"
mkdir -p ~/src/github.com/nickrwann
rm -rf ~/src/github.com/nickrwann/dev-setup
cp -r '$wslRepoPath' ~/src/github.com/nickrwann/dev-setup
"@

# Execute copy in the default WSL distro (Ubuntu-22.04 in your case).
wsl -- bash -lc "$wslCopyCommand"

# Run the WSL bootstrap script to configure packages, dotfiles, etc.
Write-Host "Running WSL bootstrap script..." -ForegroundColor Cyan
$wslBootstrapCommand = "bash ~/src/github.com/nickrwann/dev-setup/wsl/setup-wsl.sh"
wsl -- bash -lc "$wslBootstrapCommand"

Write-Host "WSL bootstrap completed." -ForegroundColor Green
