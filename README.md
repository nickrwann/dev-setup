Purpose:
Personal repo for bringing a new dev machine online.

Contents:
- `windows` holds scripts for preparing a Windows host.
- `wsl` includes bootstrap scripts for Ubuntu inside WSL.
- `dotfiles` contains shell, git, and VS Code configs.

Instructions:
- Run `windows/setup-windows.ps1` from an elevated PowerShell prompt on Windows.
- Inside Ubuntu on WSL, ensure the repository path exists by running `mkdir -p ~/src/github.com/nickrwann` before bootstrapping.
- Execute `bash wsl/bootstrap-wsl.sh` from the repo root. The script will clone `https://github.com/nickrwann/dev-setup` (or a custom `REPO_URL`) into `~/src/github.com/nickrwann/dev-setup` and then link its dotfiles.
- Dotfiles live in the `dotfiles/` folder; edit them directly to change your defaults.
