#!/bin/bash

# Check if account name provided
if [ -z "$1" ]; then
    echo "Usage: copy-public-key.sh <account_name>"
    echo "Example: copy-public-key.sh personal"
    exit 1
fi

ACCOUNT_NAME="$1"
KEY_PATH="$HOME/.ssh/id_ed25519_$ACCOUNT_NAME.pub"

# Check if key exists
if [ ! -f "$KEY_PATH" ]; then
    echo "Error: Public key not found: $KEY_PATH"
    echo ""
    echo "Available keys:"
    ls -1 "$HOME/.ssh"/*.pub 2>/dev/null
    exit 1
fi

# Try to copy to clipboard (platform-dependent)
if command -v xclip >/dev/null 2>&1; then
    # Linux with xclip
    cat "$KEY_PATH" | xclip -selection clipboard
    CLIPBOARD_CMD="xclip"
elif command -v xsel >/dev/null 2>&1; then
    # Linux with xsel
    cat "$KEY_PATH" | xsel --clipboard --input
    CLIPBOARD_CMD="xsel"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    cat "$KEY_PATH" | pbcopy
    CLIPBOARD_CMD="pbcopy"
else
    CLIPBOARD_CMD=""
fi

echo ""
if [ -n "$CLIPBOARD_CMD" ]; then
    echo "Public key copied to clipboard (using $CLIPBOARD_CMD)!"
else
    echo "Could not copy to clipboard automatically."
    echo "Please copy the key manually:"
fi
echo ""
echo "Key content:"
cat "$KEY_PATH"
echo ""
echo ""
echo "Next step: Go to GitHub > Settings > SSH and GPG keys > New SSH key"
echo "Paste the key and save it."
echo ""

