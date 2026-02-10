# dev-mode

Scripts to duplicate my Mac development environment to a new machine.

## What Gets Migrated

- **Homebrew** — All formulae and casks via Brewfile
- **Shell** — `.zshrc` + Oh My Zsh custom configs
- **SSH keys** — All key pairs (id_rsa, id_ed25519, pos-deploy)
- **Git config** — `.gitconfig` and global gitignore
- **Claude Code** — CLAUDE.md, settings, commands, skills, hooks, plugins
- **Node.js** — NVM + installed versions, pnpm
- **Go / Python** — Installed tools and pip packages list
- **Misc** — `.npmrc`, Docker config

## Usage

### On the old Mac (export)

```bash
./migrate-to-new-mac.sh
```

Creates `bundle/` inside this repo with all configs and keys. The `bundle/` directory is gitignored — it never gets pushed.

Skip Claude Code config (if already migrated separately):
```bash
./migrate-to-new-mac.sh --skip-claude
```

### Transfer to the new Mac

Copy the **entire `dev-mode/` folder** (including `bundle/`) via **AirDrop** or **USB drive**. The bundle contains SSH private keys — do NOT upload to cloud storage.

### On the new Mac (restore)

1. Install Xcode Command Line Tools first:
   ```bash
   xcode-select --install
   ```
3. Run the restore script:
   ```bash
   ./restore-on-new-mac.sh
   ```
   Skip Claude Code restore (if already set up):
   ```bash
   ./restore-on-new-mac.sh --skip-claude
   ```
4. Restart terminal

### Manual steps after restore

- Install **Docker Desktop** from docker.com
- Install **Claude Code**: `npm install -g @anthropic-ai/claude-code`
- Re-authenticate GitHub: `gh auth login`
- Test SSH: `ssh -T git@github.com`
- Clone repos from GitHub
- Reinstall Android Studio / Antigravity if needed
