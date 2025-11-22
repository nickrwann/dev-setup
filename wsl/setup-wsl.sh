#!/usr/bin/env bash
# Bootstraps the WSL (Ubuntu) environment.
# Responsibilities:
#   - Install core packages and CLI tools
#   - Install and configure starship
#   - Verify dev-setup repo presence and link dotfiles
#   - Install uv
#   - Install VS Code extensions (if code CLI is available)

set -euo pipefail

# Ensure locally installed tools are on PATH before everything else.
export PATH="$HOME/.local/bin:$PATH"

# Canonical repo base inside WSL home.
REPO_BASE="$HOME/src/github.com/nickrwann"
DEV_SETUP_DIR="$REPO_BASE/dev-setup"

# Install VS Code extensions listed in dotfiles/vscode/extensions.txt.
install_vscode_extensions() {
  local extensions_file="$DEV_SETUP_DIR/dotfiles/vscode/extensions.txt"

  # Guard if VS Code CLI is not available inside WSL.
  if ! command -v code >/dev/null 2>&1; then
    echo "VS Code command 'code' not found; skipping extension install."
    echo "Once Remote WSL is set up in VS Code, rerun this script to install extensions."
    return
  fi

  # Install each non empty, non comment line as an extension id.
  if [ -f "$extensions_file" ]; then
    echo "Installing VS Code extensions from $extensions_file..."
    while IFS= read -r extension; do
      # Strip trailing comments.
      extension="${extension%%#*}"
      # Skip empty or whitespace only lines.
      if [ -n "${extension// /}" ]; then
        echo "  -> $extension"
        code --install-extension "$extension" >/dev/null 2>&1 || \
          echo "     Could not install VS Code extension: $extension"
      fi
    done <"$extensions_file"
  else
    echo "No VS Code extensions file found at $extensions_file. Skipping."
  fi
}

echo "[1/5] Updating apt and installing core CLI tools..."

# Update package index and install core CLI tools and build dependencies.
sudo apt update
sudo apt install -y \
  build-essential \
  pkg-config \
  libssl-dev \
  libffi-dev \
  zlib1g-dev \
  curl \
  git \
  unzip \
  ca-certificates \
  ripgrep \
  fd-find \
  fzf \
  tree

echo "[2/5] Installing and configuring starship prompt..."

# Install starship prompt if it is not already present.
if ! command -v starship >/dev/null 2>&1; then
  curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# Apply the bracketed-segments preset if starship is installed.
if command -v starship >/dev/null 2>&1; then
  mkdir -p "$HOME/.config"
  # This overwrites any existing starship.toml with the bracketed preset.
  starship preset bracketed-segments -o "$HOME/.config/starship.toml"
  # Ensure directory paths are not truncated (show full path in the prompt).
  cat <<'EOF' >> "$HOME/.config/starship.toml"

[directory]
truncation_length = 0
truncate_to_repo = false
EOF
else
  echo "Starship installation appears to have failed. Prompt will not be customized."
fi

echo "[3/5] Verifying dev-setup repo location..."

# Ensure the repo base directory exists.
mkdir -p "$REPO_BASE"

# At this point windows/setup-wsl.ps1 should have copied the repo here.
if [ ! -d "$DEV_SETUP_DIR" ]; then
  echo "Expected dev-setup repo at: $DEV_SETUP_DIR"
  echo "It was not found. Run windows/setup-wsl.ps1 again or clone the repo manually."
  exit 1
fi

echo "Found dev-setup at: $DEV_SETUP_DIR"

echo "[4/5] Linking dotfiles and configuring shell..."

# Link bash and git dotfiles from the repo into $HOME.
ln -sf "$DEV_SETUP_DIR/dotfiles/bash/.bashrc" "$HOME/.bashrc"
ln -sf "$DEV_SETUP_DIR/dotfiles/git/.gitconfig" "$HOME/.gitconfig"

# Ensure starship is initialized in bash. Append once if missing.
if ! grep -q 'starship init bash' "$HOME/.bashrc"; then
  {
    echo ""
    echo "# Initialize starship prompt"
    echo 'eval "$(starship init bash)"'
  } >> "$HOME/.bashrc"
fi

echo "[5/5] Installing uv (Python toolchain) if missing..."

# Install uv if it is not already present.
if ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
else
  echo "uv is already installed."
fi

echo "Installing VS Code extensions (if VS Code CLI is available)..."
install_vscode_extensions

echo ""
echo "WSL bootstrap completed successfully."
echo "Open a new terminal or run 'exec bash' to pick up the new .bashrc and starship prompt."
