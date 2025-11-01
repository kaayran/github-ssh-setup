#!/bin/bash

# Function to test a host
test_host() {
    local host_name="$1"
    echo "Testing connection to $host_name..."
    local output=$(ssh -T "git@$host_name" 2>&1)
    local exit_code=$?
    
    # Show the output
    echo "$output"
    echo ""
    
    # GitHub returns exit code 1 even on success (because it doesn't provide shell access)
    # Check if output contains "successfully authenticated" or "does not provide shell access"
    if echo "$output" | grep -qi "successfully authenticated" || \
       echo "$output" | grep -qi "does not provide shell access"; then
        echo "Connection successful!"
    else
        echo "Connection failed or key not added to GitHub yet."
    fi
    echo ""
}

# Check if host name provided
if [ -z "$1" ]; then
    echo "Usage: test-ssh-connection.sh <host_name>"
    echo "Example: test-ssh-connection.sh github-personal"
    echo ""
    echo "Testing all configured hosts..."
    echo ""
    
    CONFIG_FILE="$HOME/.ssh/config"
    if [ -f "$CONFIG_FILE" ]; then
        # Extract all Host entries from config
        grep "^Host " "$CONFIG_FILE" | awk '{print $2}' | while read -r host; do
            # Skip if it's github.com (the actual hostname)
            if [ "$host" != "github.com" ]; then
                test_host "$host"
            fi
        done
    else
        echo "No SSH config file found."
        echo "Please run: ./scripts/linux-mac/update-ssh-config.sh"
    fi
    exit 0
fi

HOST_NAME="$1"
test_host "$HOST_NAME"

