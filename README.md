# SSH for GitHub - Quick Guide

This repository contains a quick guide and automation scripts for setting up SSH keys for GitHub on Windows, Linux, and macOS.

🌐 **Live Demo:** [https://kaayran.github.io/github-ssh-setup/](https://kaayran.github.io/github-ssh-setup/)

## Quick Start with Scripts

### Windows (cmd)

Run the setup wizard (recommended):
```cmd
scripts\windows\setup-github-ssh.bat
```

Or use individual scripts:
```cmd
REM Generate SSH key
scripts\windows\setup-ssh-key.bat

REM Copy public key to clipboard
scripts\windows\copy-public-key.bat personal

REM Update SSH config
scripts\windows\update-ssh-config.bat personal

REM Test connection
scripts\windows\test-ssh-connection.bat github-personal
```

### Linux / macOS

Make scripts executable (first time only):
```bash
chmod +x scripts/linux-mac/*.sh
```

Run the setup wizard (recommended):
```bash
./scripts/linux-mac/setup-github-ssh.sh
```

Or use individual scripts:
```bash
# Generate SSH key
./scripts/linux-mac/setup-ssh-key.sh

# Copy public key to clipboard
./scripts/linux-mac/copy-public-key.sh personal

# Update SSH config
./scripts/linux-mac/update-ssh-config.sh personal

# Test connection
./scripts/linux-mac/test-ssh-connection.sh github-personal
```

**Note:** The scripts use only built-in system commands and require no additional dependencies (no Python, Node.js, etc.)

---

## Available Scripts

This repository includes automation scripts for Windows (cmd) and Linux/macOS (bash). All scripts work with built-in system commands only.

### Master Script (Recommended for First-Time Setup)

**Windows:** `scripts\windows\setup-github-ssh.bat`  
**Linux/macOS:** `./scripts/linux-mac/setup-github-ssh.sh`

Complete setup wizard that:
- Generates a new SSH key (Ed25519)
- Copies the public key to clipboard
- Updates SSH config file automatically
- Guides you through the remaining steps

**Usage:** Just run it and follow the prompts!

### Individual Scripts

#### 1. `setup-ssh-key` - Generate SSH Key

**What it does:**
- Creates `~/.ssh` directory if it doesn't exist
- Generates a new Ed25519 SSH key pair
- Prompts for account name (e.g., "personal", "work") and email
- Checks if key already exists and asks for confirmation before overwriting
- Sets proper file permissions automatically

**Parameters:**
- `[account_name]` (optional) - Account identifier
- `[email]` (optional) - Email address for the key

**Output:**
- Private key: `~/.ssh/id_ed25519_<account_name>`
- Public key: `~/.ssh/id_ed25519_<account_name>.pub`

---

#### 2. `copy-public-key` - Copy Public Key to Clipboard

**What it does:**
- Reads the public key file for specified account
- Copies it to clipboard for easy pasting
- Displays the key content on screen
- Provides instructions for adding to GitHub

**Parameters:**
- `<account_name>` (required) - Account identifier used when generating the key

**Platform Support:**
- **Windows:** Uses `clip` command
- **Linux:** Uses `xclip` or `xsel` (if available)
- **macOS:** Uses `pbcopy`

---

#### 3. `update-ssh-config` - Update SSH Config File

**What it does:**
- Creates or updates SSH config file (`~/.ssh/config`)
- Adds a new host entry for GitHub with the specified key
- Creates a backup of existing config before modifications
- Checks if host already exists and asks for confirmation to update
- Sets proper file permissions

**Parameters:**
- `<account_name>` (required) - Account identifier
- `[host_name]` (optional) - Custom host name (defaults to `github-<account_name>`)

**Output:**
- Updated `~/.ssh/config` file
- Backup file: `~/.ssh/config.backup` (if config existed)

**Example SSH config entry created:**
```
Host github-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes
```

---

#### 4. `test-ssh-connection` - Test SSH Connection

**What it does:**
- Tests SSH connection to GitHub using configured hosts
- Can test a specific host or all configured hosts
- Properly detects successful connections (even though GitHub returns exit code 1)
- Displays connection status and GitHub's response

**Parameters:**
- `[host_name]` (optional) - Specific host to test (e.g., "github-personal")
  - If not provided, tests all configured hosts

**Output:**
- SSH connection test results
- Success/failure message based on GitHub's response
- Shows GitHub authentication message

**Note:** Even successful connections return exit code 1 from GitHub (because it doesn't provide shell access), but the script correctly detects success by checking the output message.

---

## Scripts Comparison

| Feature | Windows (.bat) | Linux/macOS (.sh) |
|---------|----------------|-------------------|
| Key Generation | ✅ | ✅ |
| Clipboard Copy | ✅ (clip) | ✅ (xclip/xsel/pbcopy) |
| Config Update | ✅ | ✅ |
| Connection Test | ✅ | ✅ |
| Wizard Script | ✅ | ✅ |
| No Dependencies | ✅ | ✅ |

For detailed documentation of each script, see [scripts/README.md](scripts/README.md).

---

## Manual Setup (Step by Step)

If you prefer to set up manually or need more control, follow the steps below:

## 1. Generating SSH Keys

```bash
# Generate a new SSH key (Ed25519 - recommended algorithm)
ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/id_ed25519_personal

# Or for a work account
ssh-keygen -t ed25519 -C "work_email@company.com" -f ~/.ssh/id_ed25519_work
```

## 2. Adding Public Key to GitHub

1. Copy the public key content:
```powershell
# Windows PowerShell - copy to clipboard
Get-Content ~/.ssh/id_ed25519_personal.pub | Set-Clipboard

# Or via Git Bash
cat ~/.ssh/id_ed25519_personal.pub | clip

# Or just read the file and copy manually
Get-Content ~/.ssh/id_ed25519_personal.pub
```

2. On GitHub:
   - Settings → SSH and GPG keys → New SSH key
   - Paste the public key and save

## 3. SSH Config Setup (for multiple accounts)

File: `C:\Users\<your_username>\.ssh\config` (or `~/.ssh/config` in PowerShell/Git Bash)

```ssh-config
# Personal account
Host github-personal
    HostName github.com
    User git
    IdentityFile C:/Users/<your_username>/.ssh/id_ed25519_personal
    IdentitiesOnly yes

# Work account
Host github-work
    HostName github.com
    User git
    IdentityFile C:/Users/<your_username>/.ssh/id_ed25519_work
    IdentitiesOnly yes
```

**Note:** Replace `<your_username>` with your Windows account name, or use `~/.ssh/` (this will be automatically expanded).

## 4. Using Different Keys

### Cloning a Repository
```bash
# Instead of: git clone git@github.com:username/repo.git
# Use:
git clone git@github-personal:username/repo.git
git clone git@github-work:company/repo.git
```

### Changing Remote URL for Existing Repository
```bash
# View current remote
git remote -v

# Change to the desired host
git remote set-url origin git@github-personal:username/repo.git
# or
git remote set-url origin git@github-work:company/repo.git
```

## 5. Testing Connection

```bash
# Test connection for personal account
ssh -T git@github-personal

# Test connection for work account
ssh -T git@github-work

# Expected response: "Hi username! You've successfully authenticated..."
```

## 6. Useful Commands

**Windows (cmd):**
```cmd
REM View all SSH keys
dir %USERPROFILE%\.ssh\

REM Check SSH key content
type %USERPROFILE%\.ssh\id_ed25519_personal.pub

REM View keys in ssh-agent (if used)
ssh-add -l
```

**Windows (PowerShell) / Linux / macOS:**
```powershell
# View all SSH keys
Get-ChildItem ~/.ssh/
# or (Linux/Mac)
ls ~/.ssh/

# Check SSH key content
Get-Content ~/.ssh/id_ed25519_personal.pub
# or (Linux/Mac)
cat ~/.ssh/id_ed25519_personal.pub

# View keys in ssh-agent (if used)
ssh-add -l
```

**Note:** With proper SSH config setup (with IdentityFile and IdentitiesOnly yes), keys are used automatically, you DON'T need to add them to the agent!

## 7. Git Configuration for Different Repositories

### Global Configuration (optional)
```bash
git config --global user.name "Your Name"
git config --global user.email "your_email@example.com"
```

### Local Configuration (for a specific repository)
```bash
git config user.name "Work Name"
git config user.email "work_email@company.com"
```

## 8. Troubleshooting

### Problem: Permission denied

**Windows:**
- Permissions are usually set automatically when generating keys
- If issues occur, check file properties in File Explorer:
  - Right-click → Properties → Security
  - Ensure access is only granted to your user
- Or via PowerShell:
```powershell
# Set permissions on private keys (owner only)
icacls "$env:USERPROFILE\.ssh\id_ed25519_*" /inheritance:r /grant:r "$env:USERNAME:(R)"
```

### Problem: Wrong key is being used
- Ensure `IdentitiesOnly yes` is specified in `config`
- Check the order of hosts in the config file
- Use explicit host when cloning

### Problem: SSH agent not working (usually NOT needed!)

**Important:** With proper SSH config setup using `IdentityFile` and `IdentitiesOnly yes`, keys are used automatically. You DON'T need to add them to the agent!

SSH agent is only needed if:
- You're using keys without a config file
- Connection issues persist even with proper config
- Windows ssh-agent didn't start automatically

```powershell
# Check ssh-agent status
Get-Service ssh-agent

# Start ssh-agent (if not running)
Start-Service ssh-agent

# Set ssh-agent to start automatically
Set-Service -Name ssh-agent -StartupType Automatic

# Add key to agent (only as a last resort)
ssh-add ~/.ssh/id_ed25519_personal

# Check added keys
ssh-add -l

# Remove all keys from agent
ssh-add -D
```

## Quick Commands for Copying

**Windows (cmd):**
```cmd
REM Public key to clipboard
type %USERPROFILE%\.ssh\id_ed25519_personal.pub | clip

REM Test connection
ssh -T git@github-personal
ssh -T git@github-work

REM Change remote to desired host
git remote set-url origin git@github-personal:username/repo.git
```

**Windows (PowerShell):**
```powershell
# Public key to clipboard
Get-Content ~/.ssh/id_ed25519_personal.pub | Set-Clipboard

# Test connection
ssh -T git@github-personal
ssh -T git@github-work

# Change remote to desired host
git remote set-url origin git@github-personal:username/repo.git
```

**Linux / macOS:**
```bash
# Public key to clipboard (Linux with xclip)
cat ~/.ssh/id_ed25519_personal.pub | xclip -selection clipboard

# Public key to clipboard (macOS)
cat ~/.ssh/id_ed25519_personal.pub | pbcopy

# Test connection
ssh -T git@github-personal
ssh -T git@github-work

# Change remote to desired host
git remote set-url origin git@github-personal:username/repo.git
```
