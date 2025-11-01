#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "========================================"
echo "  GitHub SSH Setup Wizard (Linux/Mac)"
echo "========================================"
echo ""

# Get account name
read -p "Enter account name (e.g., personal, work): " ACCOUNT_NAME
if [ -z "$ACCOUNT_NAME" ]; then
    echo "Error: Account name is required."
    exit 1
fi

# Get email
read -p "Enter your email address: " EMAIL
if [ -z "$EMAIL" ]; then
    echo "Error: Email is required."
    exit 1
fi

# Get host name (optional)
read -p "Enter host name for SSH config (default: github-$ACCOUNT_NAME): " HOST_NAME
if [ -z "$HOST_NAME" ]; then
    HOST_NAME="github-$ACCOUNT_NAME"
fi

echo ""
echo "========================================"
echo "  Step 1: Generating SSH Key"
echo "========================================"
echo ""

# Call setup-ssh-key script
"$SCRIPT_DIR/setup-ssh-key.sh" "$ACCOUNT_NAME" "$EMAIL"

if [ $? -ne 0 ]; then
    echo ""
    echo "Setup failed at key generation step."
    exit 1
fi

echo ""
echo "========================================"
echo "  Step 2: Copying Public Key"
echo "========================================"
echo ""

# Copy public key
"$SCRIPT_DIR/copy-public-key.sh" "$ACCOUNT_NAME"

echo ""
echo "========================================"
echo "  Step 3: Updating SSH Config"
echo "========================================"
echo ""

# Update SSH config
"$SCRIPT_DIR/update-ssh-config.sh" "$ACCOUNT_NAME" "$HOST_NAME"

if [ $? -ne 0 ]; then
    echo ""
    echo "Setup failed at config update step."
    exit 1
fi

echo ""
echo "========================================"
echo "  Next Steps (Manual)"
echo "========================================"
echo ""
echo "1. Go to GitHub: https://github.com/settings/keys"
echo "2. Click \"New SSH key\""
echo "3. Paste the public key (may already be in clipboard)"
echo "4. Give it a title and save"
echo ""
echo "After adding the key to GitHub, test the connection:"
echo "  ./scripts/linux-mac/test-ssh-connection.sh $HOST_NAME"
echo ""
echo "When cloning repositories, use:"
echo "  git clone git@$HOST_NAME:username/repo.git"
echo ""

