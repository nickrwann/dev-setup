# Dev setup quickstart
Bring a new Windows machine online with predictable defaults, WSL, and editor tooling.

## Layout
- `windows/` — PowerShell setup scripts for Windows and WSL.
- `wsl/` — bootstrap script that configures Ubuntu inside WSL.
- `dotfiles/` — bash, git, and VS Code defaults (settings, keybindings, extensions list).

## Setup steps
1. **Windows prerequisites (first run)**: open an elevated PowerShell session and run `windows/setup-windows.ps1`. It installs common tools (Windows Terminal, VS Code, Git/GitHub Desktop, Docker, Spotify), installs or upgrades WSL with Ubuntu 22.04, and prompts you to reboot.
2. **Initialize WSL**: after reboot, launch Ubuntu once to finish the WSL install, then from Windows run `windows/setup-wsl.ps1`. This verifies WSL is ready, clones this repo into `~/src/github.com/nickrwann/dev-setup` inside WSL, and invokes the bootstrap script inside the distro.
3. **Inside WSL**: the bootstrap (`wsl/setup-wsl.sh`) updates apt, installs build essentials and CLI tooling (ripgrep, fd, fzf, tree), installs and configures Starship, links bash/git dotfiles, ensures Starship init is appended once, installs `uv` if missing, and applies the VS Code extensions/settings in `dotfiles/vscode/` when `code` is available.

## Included tooling
- Bash aliases and Starship prompt via `dotfiles/bash/.bashrc`; Starship is configured with the bracketed segments preset and a full (non-truncated) directory path.
- Git defaults in `dotfiles/git/.gitconfig`.
- VS Code settings, keybindings, and extensions in `dotfiles/vscode/` (Codex extension is pre-listed).
- WSL bootstrap installs build essentials, uv, ripgrep/fd/fzf/tree, and applies the VS Code extension list when available.

## Customizing
Edit the dotfiles, update the VS Code extension list in `dotfiles/vscode/extensions.txt`, and rerun the WSL bootstrap to re-link.
