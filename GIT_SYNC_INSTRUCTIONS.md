# Git Sync Instructions

Your repository is ready to push to GitHub!

## Current Status

- Repository initialized with git
- Remote added: https://github.com/derkardamon/audio-receiver.git
- All files committed to `main` branch
- Ready to push

## Push to GitHub

You have two options:

### Option 1: HTTPS (Recommended - easier)

```bash
git push -u origin main
```

You'll be prompted for your GitHub credentials. Since GitHub no longer accepts passwords, you need to use a **Personal Access Token**:

1. Go to: https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Give it a name: "Audio Receiver Push"
4. Select scopes: `repo` (full control of private repositories)
5. Generate token and copy it
6. Use the token as your password when prompted

### Option 2: SSH (More secure for repeated pushes)

First, update the remote URL:
```bash
git remote set-url origin git@github.com:derkardamon/audio-receiver.git
```

Then push:
```bash
git push -u origin main
```

**Note:** You need SSH keys set up. If you haven't:
1. Generate key: `ssh-keygen -t ed25519 -C "your_email@example.com"`
2. Add to GitHub: https://github.com/settings/keys
3. Copy your public key: `cat ~/.ssh/id_ed25519.pub`

## Verify Push

After pushing, check:
```bash
git remote -v
git log --oneline
```

Visit: https://github.com/derkardamon/audio-receiver

## Making Future Changes

After making changes:

```bash
# Check what changed
git status

# Stage all changes
git add -A

# Commit with message
git commit -m "Your commit message"

# Push to GitHub
git push
```

## Pulling Changes from GitHub

If you make changes directly on GitHub or from another location:

```bash
git pull origin main
```

## Common Commands

```bash
# View commit history
git log --oneline --graph

# View remote info
git remote -v

# Check current branch
git branch

# View file changes
git diff

# Undo uncommitted changes
git checkout -- filename

# View remote branches
git branch -r
```

## Troubleshooting

### Repository Already Exists on GitHub

If the repository already has content:

```bash
# Pull existing content first
git pull origin main --allow-unrelated-histories

# Resolve any conflicts if they appear
# Then push
git push -u origin main
```

### Force Push (Caution!)

Only use if you're sure you want to overwrite GitHub:

```bash
git push -u origin main --force
```

**Warning:** This will delete any existing content on GitHub!

## Repository Structure

```
audio-receiver/
├── configs/              # Bluetooth and audio configurations
│   ├── bluetooth/
│   ├── pipewire/
│   └── wireplumber/
├── scripts/              # Helper and utility scripts
├── services/             # Systemd service files
├── install.sh            # Main installation script
├── uninstall.sh          # Removal script
└── *.md                  # Documentation files
```

All files are now tracked and ready for GitHub!
