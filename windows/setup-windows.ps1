# Bootstrap core Windows tools. VS Code extensions are installed from the WSL side.
winget install --id Microsoft.WindowsTerminal -e --source winget
winget install --id Microsoft.VisualStudioCode -e --source winget
winget install --id Git.Git -e --source winget
winget install --id GitHub.GitHubDesktop -e --source winget
winget install --id Docker.DockerDesktop -e --source winget

winget install --id Spotify.Spotify -e --source winget

wsl --install -d Ubuntu-22.04
