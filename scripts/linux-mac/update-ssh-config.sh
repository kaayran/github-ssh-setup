#!/bin/bash

# Check if account name provided
if [ -z "$1" ]; then
    echo "Usage: update-ssh-config.sh <account_name> [host_name]"
    echo "Example: update-ssh-config.sh personal github-personal"
    exit 1
fi

ACCOUNT_NAME="$1"
HOST_NAME="${2:-github-$ACCOUNT_NAME}"

SSH_DIR="$HOME/.ssh"
CONFIG_FILE="$SSH_DIR/config"
KEY_PATH="$SSH_DIR/id_ed25519_$ACCOUNT_NAME"

# Check if key exists
if [ ! -f "$KEY_PATH" ]; then
    echo "Error: SSH key not found: $KEY_PATH"
    echo "Please generate the key first: ./scripts/linux-mac/setup-ssh-key.sh"
    exit 1
fi

# Create .ssh directory if it doesn't exist
if [ ! -d "$SSH_DIR" ]; then
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
fi

# Check if config file exists, create backup if it does
if [ -f "$CONFIG_FILE" ]; then
    echo "Creating backup: $CONFIG_FILE.backup"
    cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
    
    # Check if host already exists
    if grep -q "^Host $HOST_NAME$" "$CONFIG_FILE"; then
        echo ""
        echo "Warning: Host '$HOST_NAME' already exists in config file."
        read -p "Do you want to update it? (y/N): " UPDATE
        if [ "$UPDATE" != "y" ] && [ "$UPDATE" != "Y" ]; then
            echo "Cancelled."
            exit 0
        fi
        # Remove old entry (simple approach - removes from Host to next Host or end)
        # This is a basic implementation, user might need to manually clean up
        echo "Removing old entry..."
        # Create temp file
        TEMP_FILE=$(mktemp)
        IN_HOST=false
        while IFS= read -r line; do
            if [[ "$line" =~ ^Host[[:space:]]+$HOST_NAME$ ]]; then
                IN_HOST=true
                continue
            fi
            if [ "$IN_HOST" = true ]; then
                if [[ "$line" =~ ^Host[[:space:]]+ ]] && [[ ! "$line" =~ ^Host[[:space:]]+$HOST_NAME$ ]]; then
                    IN_HOST=false
                    echo "$line" >> "$TEMP_FILE"
                    continue
                fi
                if [[ "$line" =~ ^[[:space:]]*# ]] || [[ "$line" =~ ^[[:space:]]*(HostName|User|IdentityFile|IdentitiesOnly)[[:space:]] ]]; then
                    continue
                fi
                if [[ -z "$line" ]] && [ "$IN_HOST" = true ]; then
                    IN_HOST=false
                    continue
                fi
            fi
            echo "$line" >> "$TEMP_FILE"
        done < "$CONFIG_FILE"
        mv "$TEMP_FILE" "$CONFIG_FILE"
    fi
else
    echo "Creating new SSH config file..."
    touch "$CONFIG_FILE"
    chmod 600 "$CONFIG_FILE"
fi

# Append new host entry
{
    echo ""
    echo "# $ACCOUNT_NAME account"
    echo "Host $HOST_NAME"
    echo "    HostName github.com"
    echo "    User git"
    echo "    IdentityFile $KEY_PATH"
    echo "    IdentitiesOnly yes"
} >> "$CONFIG_FILE"

echo ""
echo "SSH config updated successfully!"
echo ""
echo "Host: $HOST_NAME"
echo "Key: $KEY_PATH"
echo ""
echo "You can now use this host when cloning:"
echo "  git clone git@$HOST_NAME:username/repo.git"
echo ""
echo "To test connection: ./scripts/linux-mac/test-ssh-connection.sh $HOST_NAME"
echo ""

