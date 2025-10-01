#!/bin/bash

# Terminal Logger Log Wipe Script
# Removes all terminal log files (raw and clean)

set -e

echo "Terminal Logger Log Wipe"
echo "========================"
echo ""

# Check if log directory exists
if [[ ! -d ~/ttylogs ]]; then
    echo "❌ No log directory found at ~/ttylogs"
    echo "Nothing to wipe."
    exit 0
fi

# Count log files
RAW_COUNT=$(find ~/ttylogs/raw -name "*.log" 2>/dev/null | wc -l)
CLEAN_COUNT=$(find ~/ttylogs/clean -name "*.log" 2>/dev/null | wc -l)
TOTAL_COUNT=$((RAW_COUNT + CLEAN_COUNT))

if [[ $TOTAL_COUNT -eq 0 ]]; then
    echo "❌ No log files found in ~/ttylogs/"
    echo "Nothing to wipe."
    exit 0
fi

echo "This will permanently delete ALL terminal log files:"
echo ""
echo "• Raw logs: $RAW_COUNT files in ~/ttylogs/raw/"
echo "• Clean logs: $CLEAN_COUNT files in ~/ttylogs/clean/"
echo "• Total files: $TOTAL_COUNT"
echo ""
echo "⚠️  WARNING: This action cannot be undone!"
echo "⚠️  All your terminal session history will be lost!"
echo ""

# Show some example files
echo "Example log files that will be deleted:"
find ~/ttylogs -name "*.log" | head -5 | while read -r file; do
    echo "  • $(basename "$file")"
done
if [[ $TOTAL_COUNT -gt 5 ]]; then
    echo "  • ... and $((TOTAL_COUNT - 5)) more files"
fi
echo ""

# Confirmation prompt
read -p "Are you sure you want to delete ALL log files? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Log wipe cancelled."
    exit 0
fi

echo ""
echo "Deleting all log files..."

# Remove all log files
if [[ -d ~/ttylogs/raw ]]; then
    echo "• Removing raw logs..."
    rm -f ~/ttylogs/raw/*.log
fi

if [[ -d ~/ttylogs/clean ]]; then
    echo "• Removing clean logs..."
    rm -f ~/ttylogs/clean/*.log
fi

# Count remaining files to verify
REMAINING_RAW=$(find ~/ttylogs/raw -name "*.log" 2>/dev/null | wc -l)
REMAINING_CLEAN=$(find ~/ttylogs/clean -name "*.log" 2>/dev/null | wc -l)
REMAINING_TOTAL=$((REMAINING_RAW + REMAINING_CLEAN))

echo ""
if [[ $REMAINING_TOTAL -eq 0 ]]; then
    echo "✅ All log files have been deleted!"
    echo ""
    echo "Deleted:"
    echo "• $RAW_COUNT raw log files"
    echo "• $CLEAN_COUNT clean log files"
    echo "• Total: $TOTAL_COUNT files"
    echo ""
    echo "Terminal logging will continue to work normally."
    echo "New log files will be created as you use terminals."
else
    echo "⚠️  Warning: $REMAINING_TOTAL files still remain"
    echo "Some files may have been protected or in use."
fi
