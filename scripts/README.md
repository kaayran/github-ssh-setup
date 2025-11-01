# Automation Scripts

This directory contains native scripts for automating SSH key setup for GitHub. All scripts use only built-in system commands and require **no additional dependencies**.

## Detailed Script Documentation

---

## Windows Scripts (`windows/*.bat`)

### `setup-github-ssh.bat` - Complete Setup Wizard

**Description:** Master script that orchestrates the entire setup process.

**Input Parameters:** None (interactive prompts)

**What it does:**
1. Prompts for account name (e.g., "personal", "work")
2. Prompts for email address
3. Prompts for host name (optional, defaults to `github-<account_name>`)
4. Calls `setup-ssh-key.bat` with provided parameters
5. Calls `copy-public-key.bat` to copy public key to clipboard
6. Calls `update-ssh-config.bat` to configure SSH config
7. Displays final instructions

**Output:**
- Generated SSH key pair
- Public key copied to clipboard
- Updated SSH config file
- Instructions for adding key to GitHub

**Usage:**
```cmd
scripts\windows\setup-github-ssh.bat
```

---

### `setup-ssh-key.bat` - Generate SSH Key

**Description:** Generates a new Ed25519 SSH key pair for GitHub.

**Input Parameters:**
- `[account_name]` (optional) - Account identifier (e.g., "personal", "work")
  - If not provided, prompts interactively
- `[email]` (optional) - Email address for the key
  - If not provided, prompts interactively

**What it does:**
1. Checks if `~/.ssh` directory exists, creates if not
2. Accepts account name and email (via parameters or prompts)
3. Generates key filename: `id_ed25519_<account_name>`
4. Checks if key already exists
   - If exists, asks for confirmation to overwrite
   - If declined, exits
5. Generates SSH key using `ssh-keygen -t ed25519`
6. Displays key location and next steps

**Output:**
- Private key: `~/.ssh/id_ed25519_<account_name>`
- Public key: `~/.ssh/id_ed25519_<account_name>.pub`
- Success message with next steps

**Error Handling:**
- Validates required parameters
- Checks for key conflicts
- Reports `ssh-keygen` failures

**Usage:**
```cmd
REM Interactive mode
scripts\windows\setup-ssh-key.bat

REM With parameters
scripts\windows\setup-ssh-key.bat personal "user@example.com"
```

---

### `copy-public-key.bat` - Copy Public Key to Clipboard

**Description:** Copies the public SSH key to clipboard for easy pasting into GitHub.

**Input Parameters:**
- `<account_name>` (required) - Account identifier used when generating the key

**What it does:**
1. Validates that account name is provided
2. Constructs path to public key: `~/.ssh/id_ed25519_<account_name>.pub`
3. Checks if public key file exists
   - If not found, lists available keys and exits
4. Copies public key content to clipboard using `clip` command
5. Displays the key content on screen
6. Provides instructions for adding to GitHub

**Output:**
- Public key copied to Windows clipboard
- Key content displayed on screen
- Next step instructions

**Error Handling:**
- Validates account name parameter
- Checks if key file exists
- Lists available keys if requested key not found

**Usage:**
```cmd
scripts\windows\copy-public-key.bat personal
```

---

### `update-ssh-config.bat` - Update SSH Config File

**Description:** Adds or updates SSH config entry for GitHub host alias.

**Input Parameters:**
- `<account_name>` (required) - Account identifier
- `[host_name]` (optional) - Custom host name (defaults to `github-<account_name>`)

**What it does:**
1. Validates account name is provided
2. Sets host name (from parameter or default)
3. Checks if corresponding SSH key exists
   - If not found, displays error and exits
4. Converts Windows path to Unix-style for config file
5. Creates `.ssh` directory if it doesn't exist
6. Creates backup of existing config file (if exists)
7. Checks if host entry already exists in config
   - If exists, asks for confirmation to update
   - If declined, exits
8. Appends new host configuration entry:
   ```
   # <account_name> account
   Host <host_name>
       HostName github.com
       User git
       IdentityFile <key_path>
       IdentitiesOnly yes
   ```
9. Displays success message with usage instructions

**Output:**
- Updated `~/.ssh/config` file
- Backup file created: `~/.ssh/config.backup` (if config existed)
- Success message with host name and cloning example

**Error Handling:**
- Validates account name parameter
- Checks if SSH key exists before updating config
- Creates backup before modifications
- Handles existing host entries

**Usage:**
```cmd
REM With default host name (github-personal)
scripts\windows\update-ssh-config.bat personal

REM With custom host name
scripts\windows\update-ssh-config.bat personal github-work
```

---

### `test-ssh-connection.bat` - Test SSH Connection

**Description:** Tests SSH connection to GitHub using configured hosts.

**Input Parameters:**
- `[host_name]` (optional) - Specific host to test (e.g., "github-personal")
  - If not provided, tests all configured hosts

**What it does:**
1. If host name provided:
   - Tests connection to specified host using `ssh -T git@<host_name>`
   - Displays success/failure message
2. If no host name provided:
   - Reads SSH config file
   - Extracts all "Host" entries
   - Tests each host sequentially
3. Displays connection status for each test

**Output:**
- SSH connection test results
- Success message or error indication
- GitHub authentication response (if successful)

**Error Handling:**
- Checks if SSH config file exists (when testing all hosts)
- Reports connection failures clearly

**Usage:**
```cmd
REM Test specific host
scripts\windows\test-ssh-connection.bat github-personal

REM Test all configured hosts
scripts\windows\test-ssh-connection.bat
```

---

## Linux / macOS Scripts (`linux-mac/*.sh`)

### `setup-github-ssh.sh` - Complete Setup Wizard

**Description:** Master script that orchestrates the entire setup process.

**Input Parameters:** None (interactive prompts)

**What it does:**
1. Prompts for account name (e.g., "personal", "work")
2. Prompts for email address
3. Prompts for host name (optional, defaults to `github-<account_name>`)
4. Calls `setup-ssh-key.sh` with provided parameters
5. Calls `copy-public-key.sh` to copy public key to clipboard
6. Calls `update-ssh-config.sh` to configure SSH config
7. Displays final instructions

**Output:**
- Generated SSH key pair
- Public key copied to clipboard (if clipboard tool available)
- Updated SSH config file
- Instructions for adding key to GitHub

**Usage:**
```bash
./scripts/linux-mac/setup-github-ssh.sh
```

---

### `setup-ssh-key.sh` - Generate SSH Key

**Description:** Generates a new Ed25519 SSH key pair for GitHub.

**Input Parameters:**
- `[account_name]` (optional) - Account identifier (e.g., "personal", "work")
  - If not provided, prompts interactively
- `[email]` (optional) - Email address for the key
  - If not provided, prompts interactively

**What it does:**
1. Checks if `~/.ssh` directory exists, creates with proper permissions (700) if not
2. Accepts account name and email (via parameters or prompts)
3. Generates key filename: `id_ed25519_<account_name>`
4. Checks if key already exists
   - If exists, asks for confirmation to overwrite
   - If declined, exits
5. Generates SSH key using `ssh-keygen -t ed25519`
6. Sets proper file permissions:
   - Private key: 600 (owner read/write only)
   - Public key: 644 (owner read/write, others read)
7. Displays key location and next steps

**Output:**
- Private key: `~/.ssh/id_ed25519_<account_name>` (permissions: 600)
- Public key: `~/.ssh/id_ed25519_<account_name>.pub` (permissions: 644)
- Success message with next steps

**Error Handling:**
- Validates required parameters
- Checks for key conflicts
- Reports `ssh-keygen` failures

**Usage:**
```bash
# Interactive mode
./scripts/linux-mac/setup-ssh-key.sh

# With parameters
./scripts/linux-mac/setup-ssh-key.sh personal "user@example.com"
```

---

### `copy-public-key.sh` - Copy Public Key to Clipboard

**Description:** Copies the public SSH key to clipboard for easy pasting into GitHub.

**Input Parameters:**
- `<account_name>` (required) - Account identifier used when generating the key

**What it does:**
1. Validates that account name is provided
2. Constructs path to public key: `~/.ssh/id_ed25519_<account_name>.pub`
3. Checks if public key file exists
   - If not found, lists available keys and exits
4. Attempts to copy to clipboard using available tool:
   - **Linux:** `xclip` or `xsel` (tries both)
   - **macOS:** `pbcopy`
5. Displays clipboard method used or manual copy instructions
6. Shows key content on screen
7. Provides instructions for adding to GitHub

**Output:**
- Public key copied to clipboard (if tool available)
- Key content displayed on screen
- Next step instructions

**Error Handling:**
- Validates account name parameter
- Checks if key file exists
- Lists available keys if requested key not found
- Gracefully handles missing clipboard tools

**Requirements:**
- Linux: `xclip` or `xsel` package (optional, script works without them)
- macOS: `pbcopy` (built-in)

**Usage:**
```bash
./scripts/linux-mac/copy-public-key.sh personal
```

---

### `update-ssh-config.sh` - Update SSH Config File

**Description:** Adds or updates SSH config entry for GitHub host alias.

**Input Parameters:**
- `<account_name>` (required) - Account identifier
- `[host_name]` (optional) - Custom host name (defaults to `github-<account_name>`)

**What it does:**
1. Validates account name is provided
2. Sets host name (from parameter or default)
3. Checks if corresponding SSH key exists
   - If not found, displays error and exits
4. Creates `.ssh` directory with proper permissions (700) if it doesn't exist
5. Creates backup of existing config file (if exists): `~/.ssh/config.backup`
6. Checks if host entry already exists in config
   - If exists, asks for confirmation to update
   - If confirmed, removes old entry (from "Host" line to next "Host" or end)
   - If declined, exits
7. Appends new host configuration entry:
   ```
   # <account_name> account
   Host <host_name>
       HostName github.com
       User git
       IdentityFile <key_path>
       IdentitiesOnly yes
   ```
8. Sets config file permissions to 600 (owner read/write only)
9. Displays success message with usage instructions

**Output:**
- Updated `~/.ssh/config` file (permissions: 600)
- Backup file created: `~/.ssh/config.backup` (if config existed)
- Success message with host name and cloning example

**Error Handling:**
- Validates account name parameter
- Checks if SSH key exists before updating config
- Creates backup before modifications
- Handles existing host entries (removes old entry before adding new)

**Usage:**
```bash
# With default host name (github-personal)
./scripts/linux-mac/update-ssh-config.sh personal

# With custom host name
./scripts/linux-mac/update-ssh-config.sh personal github-work
```

---

### `test-ssh-connection.sh` - Test SSH Connection

**Description:** Tests SSH connection to GitHub using configured hosts.

**Input Parameters:**
- `[host_name]` (optional) - Specific host to test (e.g., "github-personal")
  - If not provided, tests all configured hosts

**What it does:**
1. If host name provided:
   - Tests connection to specified host using `ssh -T git@<host_name>`
   - Displays success/failure message
2. If no host name provided:
   - Reads SSH config file
   - Extracts all "Host" entries using `grep` and `awk`
   - Skips "github.com" (actual hostname, not alias)
   - Tests each host sequentially
3. Displays connection status for each test

**Output:**
- SSH connection test results
- Success message or error indication
- GitHub authentication response (if successful)

**Error Handling:**
- Checks if SSH config file exists (when testing all hosts)
- Reports connection failures clearly
- Handles missing hosts gracefully

**Usage:**
```bash
# Test specific host
./scripts/linux-mac/test-ssh-connection.sh github-personal

# Test all configured hosts
./scripts/linux-mac/test-ssh-connection.sh
```

---

## Quick Start

### First Time Setup (Linux / macOS)

Make scripts executable:

```bash
chmod +x scripts/linux-mac/*.sh
```

### Complete Setup (Recommended)

**Windows:**
```cmd
scripts\windows\setup-github-ssh.bat
```

**Linux / macOS:**
```bash
./scripts/linux-mac/setup-github-ssh.sh
```

### Manual Step-by-Step Setup

**Windows:**
```cmd
REM Step 1: Generate key
scripts\windows\setup-ssh-key.bat

REM Step 2: Copy public key
scripts\windows\copy-public-key.bat personal

REM Step 3: Update SSH config
scripts\windows\update-ssh-config.bat personal

REM Step 4: Test connection (after adding key to GitHub)
scripts\windows\test-ssh-connection.bat github-personal
```

**Linux / macOS:**
```bash
# Step 1: Generate key
./scripts/linux-mac/setup-ssh-key.sh

# Step 2: Copy public key
./scripts/linux-mac/copy-public-key.sh personal

# Step 3: Update SSH config
./scripts/linux-mac/update-ssh-config.sh personal

# Step 4: Test connection (after adding key to GitHub)
./scripts/linux-mac/test-ssh-connection.sh github-personal
```

## Requirements

- **Windows:** Windows 10+ with OpenSSH client (usually pre-installed)
- **Linux:** OpenSSH client (`openssh-client` package)
- **macOS:** OpenSSH client (pre-installed)

**Optional (for clipboard on Linux):**
- `xclip` or `xsel` package (for automatic clipboard copying)

No Python, Node.js, or other dependencies required!

## File Locations

All scripts work with standard SSH locations:

- **Windows:** `C:\Users\<username>\.ssh\`
- **Linux / macOS:** `~/.ssh/`

Generated files:
- Private keys: `~/.ssh/id_ed25519_<account_name>`
- Public keys: `~/.ssh/id_ed25519_<account_name>.pub`
- Config file: `~/.ssh/config`
- Backup file: `~/.ssh/config.backup` (created automatically)
