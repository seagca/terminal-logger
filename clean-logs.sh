#!/bin/bash

# Clean Logs Script
# Creates clean versions of raw logs based on configuration

LOG_DIR="${HOME}/ttylogs"
CONFIG_FILE="${HOME}/.terminal-logger.conf"

# Load configuration
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
fi

# Set defaults for any missing variables
ENABLE_DUAL_LOGGING="${ENABLE_DUAL_LOGGING:-true}"
CLEAN_LOG_OPTIONS="${CLEAN_LOG_OPTIONS:-commands}"

# Function to clean log content
clean_log_content() {
    local content="$1"
    
    # Remove all ANSI escape sequences and control characters
    content=$(echo "$content" | sed -E 's/\x1b\[[0-9;]*[a-zA-Z]//g')
    content=$(echo "$content" | sed -E 's/\[\?2004[hl]//g')
    content=$(echo "$content" | sed -E 's/\[\?[0-9;]*[a-zA-Z]//g')
    content=$(echo "$content" | sed -E 's/\[\[0-9;]*[a-zA-Z]//g')
    content=$(echo "$content" | sed -E 's/\[\[0-9;]*[a-zA-Z]//g')
    content=$(echo "$content" | sed -E 's/\x1b//g')
    content=$(echo "$content" | sed -E 's/\x08//g')
    
    case "$CLEAN_LOG_OPTIONS" in
        "commands")
            # Extract only commands and outputs
            echo "$content" | grep -E '^[^[:space:]]+@[^[:space:]]+:|^[^[:space:]]+@[^[:space:]]+.*$|^[[:space:]]*$|^[^[:space:]]+.*$'
            ;;
        "minimal"|"full")
            # Return cleaned content
            echo "$content"
            ;;
    esac
}

# Process all raw logs
if [[ "$ENABLE_DUAL_LOGGING" == "true" ]]; then
    for raw_file in "$LOG_DIR/raw"/*.log; do
        if [[ -f "$raw_file" ]]; then
            filename=$(basename "$raw_file")
            clean_file="$LOG_DIR/clean/$filename"
            
            # Create clean log if it doesn't exist or is older than raw log
            if [[ ! -f "$clean_file" ]] || [[ "$raw_file" -nt "$clean_file" ]]; then
                echo "Processing $filename..."
                clean_log_content "$(cat "$raw_file")" > "$clean_file"
            fi
        fi
    done
fi
