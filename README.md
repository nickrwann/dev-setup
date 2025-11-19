Purpose:
Personal repo for bringing a new dev machine online.

Contents:
- `windows` holds scripts for preparing a Windows host.
- `wsl` includes bootstrap scripts for Ubuntu inside WSL.
- `dotfiles` contains shell, git, and VS Code configs.

Instructions:
- Run `windows/setup-windows.ps1` from an elevated PowerShell prompt on Windows.
- Inside Ubuntu on WSL, execute `bash wsl/setup-wsl.sh`.
- Dotfiles live in the `dotfiles/` folder; edit them directly to change your defaults.
