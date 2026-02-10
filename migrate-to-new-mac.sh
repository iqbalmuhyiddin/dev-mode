#!/bin/bash
# =============================================================
# Mac Dev Environment Migration Script
# Run this on the OLD Mac to create a migration bundle
# =============================================================

set -e

SKIP_CLAUDE=false
for arg in "$@"; do
  case $arg in
    --skip-claude) SKIP_CLAUDE=true ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
EXPORT_DIR="$SCRIPT_DIR/bundle"
mkdir -p "$EXPORT_DIR"

echo "=== 1. Homebrew ==="
brew bundle dump --file="$EXPORT_DIR/Brewfile" --force
echo "Brewfile saved."

echo "=== 2. Shell config ==="
cp ~/.zshrc "$EXPORT_DIR/zshrc"
cp -r ~/.oh-my-zsh/custom "$EXPORT_DIR/omz-custom" 2>/dev/null || echo "No OMZ custom dir"

echo "=== 3. SSH keys ==="
cp -r ~/.ssh "$EXPORT_DIR/dot-ssh"
echo "SSH keys copied. KEEP THIS BUNDLE SECURE."

echo "=== 4. Git config ==="
cp ~/.gitconfig "$EXPORT_DIR/gitconfig" 2>/dev/null || echo "No .gitconfig"
cp ~/.gitignore_global "$EXPORT_DIR/gitignore_global" 2>/dev/null || echo "No global gitignore"

if [ "$SKIP_CLAUDE" = false ]; then
  echo "=== 5. Claude Code config ==="
  mkdir -p "$EXPORT_DIR/dot-claude"
  cp ~/.claude/CLAUDE.md "$EXPORT_DIR/dot-claude/" 2>/dev/null
  cp ~/.claude/settings.json "$EXPORT_DIR/dot-claude/" 2>/dev/null
  cp -r ~/.claude/commands "$EXPORT_DIR/dot-claude/" 2>/dev/null
  cp -r ~/.claude/skills "$EXPORT_DIR/dot-claude/" 2>/dev/null
  cp -r ~/.claude/hooks "$EXPORT_DIR/dot-claude/" 2>/dev/null
  cp -r ~/.claude/plugins "$EXPORT_DIR/dot-claude/" 2>/dev/null
  echo "Claude Code config copied."
else
  echo "=== 5. Claude Code config === SKIPPED"
fi

echo "=== 6. NVM / Node versions ==="
nvm ls --no-colors > "$EXPORT_DIR/nvm-versions.txt" 2>/dev/null
echo "Node versions recorded."

echo "=== 7. pnpm global packages ==="
pnpm list -g --depth=0 > "$EXPORT_DIR/pnpm-globals.txt" 2>/dev/null || echo "No pnpm globals"

echo "=== 8. Go tools ==="
ls ~/go/bin/ > "$EXPORT_DIR/go-tools.txt" 2>/dev/null || echo "No go tools"

echo "=== 9. Python pip packages ==="
pip3 list --format=freeze > "$EXPORT_DIR/pip-packages.txt" 2>/dev/null || echo "No pip packages"

echo "=== 10. SSH config ==="
# Already copied with ~/.ssh, but flag it
echo "SSH config is in dot-ssh/config"

echo "=== 11. Misc dotfiles ==="
cp ~/.npmrc "$EXPORT_DIR/npmrc" 2>/dev/null || true
cp ~/.docker/config.json "$EXPORT_DIR/docker-config.json" 2>/dev/null || true

echo ""
echo "============================================"
echo "Migration bundle created at: $EXPORT_DIR"
echo "============================================"
echo ""
echo "Bundle is inside the repo at: $EXPORT_DIR"
echo "Transfer this entire dev-mode folder to the new Mac."
echo "IMPORTANT: bundle/ contains SSH private keys — do NOT push to git."
echo "  Use AirDrop, USB drive, or scp."
