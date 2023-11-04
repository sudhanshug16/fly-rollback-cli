#!/bin/bash

# Check if the script is running with root permissions
if [ "$EUID" -ne 0 ]
  then echo "Please run as root or use sudo"
  exit
fi

# Check if fly-rollback is already installed
if command -v fly-rollback >/dev/null 2>&1; then
    echo "fly-rollback is already installed. Updating..."
    rm -f /usr/local/bin/fly-rollback
else
    echo "Installing fly-rollback..."
fi

# Copy the script to /usr/local/bin
cp ./fly-rollback.sh /usr/local/bin/fly-rollback

# Make the script executable
chmod +x /usr/local/bin/fly-rollback

echo "Installation successful. You can now use fly-rollback command."
