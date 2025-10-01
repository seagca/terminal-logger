#!/bin/bash

# Terminal Logger Installation Script - Simple Version
# Sets up automatic terminal logging via bashrc

set -e

echo "Installing Terminal Logger (Simple Version)..."

# Make all shell scripts executable
echo "• Making scripts executable..."
chmod +x *.sh

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "This script should not be run as root. Please run as a regular user."
   exit 1
fi

# Create log directory
mkdir -p ~/ttylogs
chmod 700 ~/ttylogs

# Create user config
if [[ ! -f ~/.terminal-logger.conf ]]; then
    cp config.conf ~/.terminal-logger.conf
    echo "Created user configuration at ~/.terminal-logger.conf"
fi

# Run the bashrc setup
./setup-bashrc.sh

echo ""
echo "✅ Installation complete!"
echo ""
echo "What happens now:"
echo "- Every new terminal will automatically start logging"
echo "- Logs stored in ~/ttylogs/ with timestamps"
echo "- Captures EVERYTHING: commands, outputs, errors"
echo "- Configurable log rotation"
echo ""
echo "To test:"
echo "  source ~/.bashrc"
echo "  # or just open a new terminal"
echo ""
echo "To view logs:"
echo "  python3 viewer.py"
echo "  python3 viewer.py --list"
echo "  python3 viewer.py --search 'git'"
echo ""
echo "To configure:"
echo "  edit ~/.terminal-logger.conf"
echo ""
echo "To disable:"
echo "  Remove the terminal logger section from ~/.bashrc"
