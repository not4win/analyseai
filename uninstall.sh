#!/bin/bash

echo "Uninstalling analyseai..."

# Stop and remove service
echo "Stopping service..."
launchctl unload ~/Library/LaunchAgents/com.analyseai.service.plist 2>/dev/null || true
rm -f ~/Library/LaunchAgents/com.analyseai.service.plist

# Remove from .bashrc
if [ -f ~/.bashrc ]; then
    echo "Removing from .bashrc..."
    TMP_FILE=$(mktemp)
    sed '/# analyseai configuration/,+3d' ~/.bashrc > $TMP_FILE
    mv $TMP_FILE ~/.bashrc
fi

# Remove from .zshrc
if [ -f ~/.zshrc ]; then
    echo "Removing from .zshrc..."
    TMP_FILE=$(mktemp)
    sed '/# analyseai configuration/,+3d' ~/.zshrc > $TMP_FILE
    mv $TMP_FILE ~/.zshrc
fi

# Ask if user wants to remove downloaded models
echo ""
read -p "Do you want to remove downloaded models and logs? (approx. 100MB) [y/N] " response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "Removing model files and logs..."
    rm -rf ~/.cache/analyseai
    rm -rf ~/.analyseai
fi

echo ""
echo "Uninstallation complete!"
echo "You may want to restart your terminal or source your shell configuration file." 