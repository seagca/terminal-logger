#!/bin/bash

# Setup script to add terminal logging to bashrc
# This is the SIMPLE approach - no systemd needed!

echo "Setting up automatic terminal logging..."

# Check if already configured
if grep -q "SCRIPT_RUNNING" ~/.bashrc; then
    echo "Terminal logging already configured in ~/.bashrc"
    exit 0
fi

# Create log directory
mkdir -p ~/ttylogs
chmod 700 ~/ttylogs

# Add logging to bashrc
cat >> ~/.bashrc << 'EOF'

# Terminal Logger - Simple Version
# Only start if it's an interactive shell and not already running
if [[ $- == *i* ]] && [[ -z "$SCRIPT_RUNNING" ]]; then
    export SCRIPT_RUNNING=1
    # Create log directories if they don't exist
    mkdir -p ~/ttylogs/raw
    mkdir -p ~/ttylogs/clean
    chmod 700 ~/ttylogs
    chmod 700 ~/ttylogs/raw
    chmod 700 ~/ttylogs/clean
    
    # Load configuration if it exists
    if [[ -f ~/.terminal-logger.conf ]]; then
        source ~/.terminal-logger.conf
    fi
    
    # Set defaults for any missing variables
    MAX_LOG_SIZE="${MAX_LOG_SIZE:-10MB}"
    MAX_LOG_DAYS="${MAX_LOG_DAYS:-30}"
    ROTATION_MODE="${ROTATION_MODE:-size}"
    ENABLE_DUAL_LOGGING="${ENABLE_DUAL_LOGGING:-true}"
    CLEAN_LOG_OPTIONS="${CLEAN_LOG_OPTIONS:-commands}"
    
    # Function to convert size to bytes
    size_to_bytes() {
        local size="$1"
        if [[ "$size" =~ ^([0-9]+)MB?$ ]]; then
            echo $((${BASH_REMATCH[1]} * 1024 * 1024))
        elif [[ "$size" =~ ^([0-9]+)KB?$ ]]; then
            echo $((${BASH_REMATCH[1]} * 1024))
        elif [[ "$size" =~ ^([0-9]+)GB?$ ]]; then
            echo $((${BASH_REMATCH[1]} * 1024 * 1024 * 1024))
        else
            echo "$size"
        fi
    }
    
    # Function to rotate logs
    rotate_logs() {
        case "$ROTATION_MODE" in
            "size")
                local max_bytes=$(size_to_bytes "$MAX_LOG_SIZE")
                local total_size=$(du -sb ~/ttylogs 2>/dev/null | cut -f1)
                if [[ -n "$total_size" && $total_size -gt $max_bytes ]]; then
                    find ~/ttylogs -name "*.log" -type f -printf '%T@ %p\n' | sort -n | head -n -1 | cut -d' ' -f2- | xargs rm -f
                fi
                ;;
            "time")
                find ~/ttylogs -name "*.log" -type f -mtime +$MAX_LOG_DAYS -delete
                ;;
            "never")
                # Do nothing
                ;;
        esac
    }
    
    # Rotate logs if needed
    rotate_logs
    
    # Create timestamped log files
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)-$$
    RAW_LOGFILE=~/ttylogs/raw/${TIMESTAMP}.log
    CLEAN_LOGFILE=~/ttylogs/clean/${TIMESTAMP}.log
    
    # Start logging with wrapper script that handles cleanup
    exec ~/terminal-logger/terminal-wrapper.sh "$RAW_LOGFILE" "$CLEAN_LOGFILE"
fi
EOF

echo "✅ Terminal logging configured!"
echo ""
echo "What this does:"
echo "- Every terminal session will be automatically logged"
echo "- Logs stored in ~/ttylogs/ with timestamp"
echo "- Captures EVERYTHING: commands, outputs, errors"
echo "- Prevents multiple logging instances"
echo "- Configurable log rotation"
echo ""
echo "To start logging:"
echo "  source ~/.bashrc"
echo "  # or just open a new terminal"
echo ""
echo "To view logs:"
echo "  ls ~/ttylogs/"
echo "  cat ~/ttylogs/*.log"
echo ""
echo "To configure:"
echo "  cp config.conf ~/.terminal-logger.conf"
echo "  edit ~/.terminal-logger.conf"
echo ""
echo "To disable:"
echo "  Remove the terminal logger section from ~/.bashrc"
