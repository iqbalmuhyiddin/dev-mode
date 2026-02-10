#!/bin/bash
# =============================================================
# Mac Dev Environment Restore Script
# Run this on the NEW Mac after transferring the migration bundle
# =============================================================

set -e

SKIP_CLAUDE=false
for arg in "$@"; do
  case $arg in
    --skip-claude) SKIP_CLAUDE=true ;;
  esac
done

BUNDLE_DIR="$HOME/mac-migration-bundle"

if [ ! -d "$BUNDLE_DIR" ]; then
  echo "ERROR: Migration bundle not found at $BUNDLE_DIR"
  echo "Transfer the bundle from your old Mac first."
  exit 1
fi

echo "=== 1. Install Homebrew ==="
if ! command -v brew &> /dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add to path for Apple Silicon
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "=== 2. Install Homebrew packages ==="
brew bundle --file="$BUNDLE_DIR/Brewfile"

echo "=== 3. Install Oh My Zsh ==="
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo "=== 4. Restore shell config ==="
cp "$BUNDLE_DIR/zshrc" ~/.zshrc
if [ -d "$BUNDLE_DIR/omz-custom" ]; then
  cp -r "$BUNDLE_DIR/omz-custom/"* ~/.oh-my-zsh/custom/ 2>/dev/null || true
fi

echo "=== 5. Restore SSH keys ==="
mkdir -p ~/.ssh
cp -r "$BUNDLE_DIR/dot-ssh/"* ~/.ssh/
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_* ~/.ssh/pos-deploy ~/.ssh/config 2>/dev/null || true
chmod 644 ~/.ssh/*.pub 2>/dev/null || true

echo "=== 6. Restore Git config ==="
cp "$BUNDLE_DIR/gitconfig" ~/.gitconfig 2>/dev/null || true
cp "$BUNDLE_DIR/gitignore_global" ~/.gitignore_global 2>/dev/null || true

echo "=== 7. Install NVM + Node ==="
if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi
nvm install 22
nvm use 22

echo "=== 8. Install pnpm ==="
if ! command -v pnpm &> /dev/null; then
  npm install -g pnpm
fi

if [ "$SKIP_CLAUDE" = false ]; then
  echo "=== 9. Restore Claude Code config ==="
  mkdir -p ~/.claude
  if [ -d "$BUNDLE_DIR/dot-claude" ]; then
    cp "$BUNDLE_DIR/dot-claude/CLAUDE.md" ~/.claude/ 2>/dev/null || true
    cp "$BUNDLE_DIR/dot-claude/settings.json" ~/.claude/ 2>/dev/null || true
    cp -r "$BUNDLE_DIR/dot-claude/commands" ~/.claude/ 2>/dev/null || true
    cp -r "$BUNDLE_DIR/dot-claude/skills" ~/.claude/ 2>/dev/null || true
    cp -r "$BUNDLE_DIR/dot-claude/hooks" ~/.claude/ 2>/dev/null || true
    cp -r "$BUNDLE_DIR/dot-claude/plugins" ~/.claude/ 2>/dev/null || true
  fi
else
  echo "=== 9. Restore Claude Code config === SKIPPED"
fi

echo "=== 10. Restore misc dotfiles ==="
cp "$BUNDLE_DIR/npmrc" ~/.npmrc 2>/dev/null || true
mkdir -p ~/.docker
cp "$BUNDLE_DIR/docker-config.json" ~/.docker/config.json 2>/dev/null || true

echo ""
echo "============================================"
echo "Restore complete!"
echo "============================================"
echo ""
echo "Manual steps remaining:"
echo "  1. Restart terminal (or: source ~/.zshrc)"
if [ "$SKIP_CLAUDE" = false ]; then
  echo "  2. Install Claude Code: npm install -g @anthropic-ai/claude-code"
fi
echo "  3. Install Go tools:    cat $BUNDLE_DIR/go-tools.txt"
echo "  4. Clone your repos from GitHub"
echo "  5. Docker Desktop: install from docker.com"
echo "  6. Antigravity: reinstall if needed"
echo "  7. Android Studio: install separately if needed"
echo "  8. Test SSH: ssh -T git@github.com"
echo "  9. Re-authenticate: gh auth login"
