#!/bin/bash

# Terminal Wrapper Script
# Handles cleanup when terminal session ends

RAW_LOGFILE="$1"
CLEAN_LOGFILE="$2"

# Function to clean logs when session ends
cleanup_session() {
    # Run clean-logs script to create clean version
    if [[ -f ~/terminal-logger/clean-logs.sh ]]; then
        ~/terminal-logger/clean-logs.sh >/dev/null 2>&1
    fi
}

# Trap to clean logs on exit
trap cleanup_session EXIT

# Start logging with script command and bash
script -q -f -c bash "$RAW_LOGFILE"

# This line will be reached when bash exits
cleanup_session
