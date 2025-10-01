#!/bin/bash

# Terminal Logger Uninstall Script
# Removes terminal logging from bashrc and cleans up files

set -e

echo "Terminal Logger Uninstaller"
echo "=========================="
echo ""

# Check if terminal logging is installed
if ! grep -q "SCRIPT_RUNNING" ~/.bashrc; then
    echo "❌ Terminal logging is not installed in ~/.bashrc"
    echo "Nothing to uninstall."
    exit 0
fi

echo "This will remove terminal logging from your system:"
echo ""
echo "• Remove logging code from ~/.bashrc"
echo "• Remove configuration file ~/.terminal-logger.conf"
echo "• Remove terminal wrapper script"
echo "• Remove clean logs script"
echo ""
echo "⚠️  WARNING: This will stop all terminal logging!"
echo "⚠️  Your existing log files will remain untouched."
echo ""

# Confirmation prompt
read -p "Are you sure you want to uninstall terminal logging? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Uninstall cancelled."
    exit 0
fi

echo ""
echo "Uninstalling terminal logging..."

# Remove terminal logger section from bashrc
echo "• Removing logging code from ~/.bashrc..."
sed -i '/# Terminal Logger - Simple Version/,/^fi$/d' ~/.bashrc

# Remove configuration file
if [[ -f ~/.terminal-logger.conf ]]; then
    echo "• Removing configuration file ~/.terminal-logger.conf..."
    rm ~/.terminal-logger.conf
fi


echo ""
echo "✅ Terminal logging has been uninstalled!"
echo ""
echo "What was removed:"
echo "• Terminal logging code from ~/.bashrc"
echo "• Configuration file ~/.terminal-logger.conf"
echo "• Terminal wrapper script"
echo "• Clean logs script"
echo ""
echo "What remains:"
echo "• Log files in ~/ttylogs/ (raw and clean)"
echo "• Terminal logger project files in ~/terminal-logger/"
echo "• Viewer script (python3 viewer.py)"
echo ""
echo "To completely remove everything:"
echo "  rm -rf ~/ttylogs/"
echo "  rm -rf ~/terminal-logger/"
echo ""
echo "To reinstall later:"
echo "  cd ~/terminal-logger && ./install.sh"
