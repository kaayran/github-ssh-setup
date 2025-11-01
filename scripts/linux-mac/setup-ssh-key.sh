#!/bin/bash

# Check if SSH directory exists, create if not
if [ ! -d "$HOME/.ssh" ]; then
    echo "Creating .ssh directory..."
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
fi

# Get account name
if [ -z "$1" ]; then
    read -p "Enter account name (e.g., personal, work): " ACCOUNT_NAME
else
    ACCOUNT_NAME="$1"
fi

if [ -z "$ACCOUNT_NAME" ]; then
    echo "Error: Account name is required."
    exit 1
fi

# Get email
if [ -z "$2" ]; then
    read -p "Enter your email address: " EMAIL
else
    EMAIL="$2"
fi

if [ -z "$EMAIL" ]; then
    echo "Error: Email is required."
    exit 1
fi

# Generate key filename
KEY_NAME="id_ed25519_$ACCOUNT_NAME"
KEY_PATH="$HOME/.ssh/$KEY_NAME"

# Check if key already exists
if [ -f "$KEY_PATH" ]; then
    echo ""
    echo "Warning: Key file already exists: $KEY_PATH"
    read -p "Do you want to overwrite it? (y/N): " OVERWRITE
    if [ "$OVERWRITE" != "y" ] && [ "$OVERWRITE" != "Y" ]; then
        echo "Cancelled."
        exit 0
    fi
fi

# Generate SSH key
echo ""
echo "Generating SSH key..."
ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY_PATH" -N ""

if [ $? -ne 0 ]; then
    echo ""
    echo "Error: Failed to generate SSH key."
    exit 1
fi

# Set proper permissions
chmod 600 "$KEY_PATH"
chmod 644 "$KEY_PATH.pub"

echo ""
echo "SSH key generated successfully!"
echo ""
echo "Key location: $KEY_PATH"
echo "Public key: $KEY_PATH.pub"
echo ""
echo "Next steps:"
echo "1. Copy your public key: ./scripts/linux-mac/copy-public-key.sh $ACCOUNT_NAME"
echo "2. Add it to GitHub: Settings > SSH and GPG keys > New SSH key"
echo "3. Update SSH config: ./scripts/linux-mac/update-ssh-config.sh $ACCOUNT_NAME"
echo ""

