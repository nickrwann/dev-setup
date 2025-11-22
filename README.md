# Dev setup quickstart
Personal repo for bringing a new dev machine online with predictable defaults and editor tooling.

## What lives here
- `windows/` installs the base tools on Windows (including Git for Windows) and kicks off WSL.
- `wsl/` bootstraps Ubuntu inside WSL, installs CLI tools, and wires dotfiles.
- `dotfiles/` holds bash, git, and VS Code defaults (settings, keybindings, extensions list).

## How to use it
1) On Windows, open an elevated PowerShell session and run `windows/setup-windows.ps1`.
2) Launch Ubuntu (installed by the Windows script) and run `bash wsl/setup-wsl.sh`.
3) Open VS Code; the extension list and settings in `dotfiles/vscode/` will be applied automatically when the WSL script runs and `code` is available.

## Included tooling
- Bash aliases and Starship prompt via `dotfiles/bash/.bashrc`.
- Git defaults in `dotfiles/git/.gitconfig`.
- VS Code settings, keybindings, and extensions in `dotfiles/vscode/` (Codex extension is pre-listed).
- WSL script installs build essentials, uv, ripgrep/fd/fzf, and applies the extension list when `code` is available.
- Install additional tooling as needed (e.g., `uv tool install codex-cli`).

## Customizing
Edit dotfiles directly, add or remove VS Code extensions in `dotfiles/vscode/extensions.txt`, and rerun the WSL script to re-link.
