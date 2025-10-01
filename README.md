# Terminal Logger

> ⚠️ **WARNING**: This tool logs EVERYTHING including passwords, sensitive data, and personal information. Use at your own risk. The authors are not responsible for any data loss, security breaches, or system issues.

A simple terminal session logger that automatically records **everything** you do in the terminal - commands, outputs, errors - exactly as you see them.

## Features

- ✅ **Complete Capture**: Records EVERYTHING - commands, outputs, errors, everything you see
- ✅ **Dual Logging**: Both raw logs (with control sequences) and clean logs (readable)
- ✅ **Separate Folders**: Raw logs in `~/ttylogs/raw/`, clean logs in `~/ttylogs/clean/`
- ✅ **Configurable Clean Options**: Choose what to include in clean logs
- ✅ **Automatic Start**: Works immediately, no systemd services needed
- ✅ **Configurable Rotation**: Delete logs after X days, when size limit reached, or never
- ✅ **No Recursion**: Prevents multiple logging instances
- ✅ **Lightweight**: Uses built-in `script` command, minimal overhead

## Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/seagca/terminal-logger.git
cd terminal-logger

# Make install script executable and install
chmod +x install.sh
./install.sh
```

### Start Logging

```bash
# Reload bashrc to start logging
source ~/.bashrc

# Or just open a new terminal - logging starts automatically!
```

### View Logs

```bash
# View recent terminal sessions (both raw and clean)
python3 viewer.py

# List all log files
python3 viewer.py --list

# List only clean logs
python3 viewer.py --list --type clean

# List only raw logs
python3 viewer.py --list --type raw

# Search for specific text
python3 viewer.py --search "git commit"

# Search only in clean logs
python3 viewer.py --search "git commit" --type clean

# View specific log file
python3 viewer.py --show 20240115-143022-12345.log
```

## Configuration

Edit `~/.terminal-logger.conf` to customize behavior:

```bash
# Log rotation mode: size, time, or never
ROTATION_MODE="size"

# Maximum log size before rotation (size mode)
MAX_LOG_SIZE="10MB"

# Maximum days to keep logs (time mode)
MAX_LOG_DAYS="30"

# Dual logging options
ENABLE_DUAL_LOGGING="true"

# Clean log options: commands, minimal, or full
CLEAN_LOG_OPTIONS="commands"
```

### Rotation Modes

- **`size`**: Delete oldest logs when total size exceeds `MAX_LOG_SIZE`
- **`time`**: Delete logs older than `MAX_LOG_DAYS` days
- **`never`**: Keep all logs forever

### Dual Logging Options

- **`ENABLE_DUAL_LOGGING="true"`**: Enable both raw and clean logs
- **`ENABLE_DUAL_LOGGING="false"`**: Only raw logs (original behavior)

### Clean Log Options

- **`commands`**: Only commands and outputs, remove control sequences
- **`minimal`**: Remove all control sequences but keep everything else
- **`full`**: Same as raw but with control sequences removed

## Log Format

### Raw Logs (`~/ttylogs/raw/`)
Raw logs contain **exactly** what you saw in your terminal, including all control sequences:

```
Script started on 2024-01-15 14:30:22+00:00 [TERM="xterm-256color" TTY="/dev/pts/1"]
[?2004h]0;user@computer: ~[01;32muser@computer[00m:[01;34m~ $[00m ls -la
[?2004l
total 48
drwxr-xr-x  5 user user 4096 Jan 15 14:30 .
drwxr-xr-x 20 user user 4096 Jan 15 14:25 ..
-rw-r--r--  1 user user  220 Jan 15 14:25 .bashrc
[?2004h]0;user@computer: ~[01;32muser@computer[00m:[01;34m~ $[00m exit
[?2004l
exit

Script done on 2024-01-15 14:35:10+00:00
```

### Clean Logs (`~/ttylogs/clean/`)
Clean logs are much more readable with control sequences removed:

```
Script started on 2024-01-15 14:30:22+00:00
user@computer:~$ ls -la
total 48
drwxr-xr-x  5 user user 4096 Jan 15 14:30 .
drwxr-xr-x 20 user user 4096 Jan 15 14:25 ..
-rw-r--r--  1 user user  220 Jan 15 14:25 .bashrc
user@computer:~$ exit
exit

Script done on 2024-01-15 14:35:10+00:00
```

**What's captured:**
- ✅ Every command you type
- ✅ Every output from commands
- ✅ Every error message
- ✅ Directory changes
- ✅ Complete terminal session
- ✅ Timestamps (start/end)

## Usage Examples

### Basic Log Viewing

```bash
# Show recent terminal sessions (both raw and clean)
python3 viewer.py

# Show recent 10 sessions
python3 viewer.py --recent 10

# List all log files with details
python3 viewer.py --list

# List only clean logs
python3 viewer.py --list --type clean

# List only raw logs
python3 viewer.py --list --type raw
```

### Searching and Analysis

```bash
# Find all git commands
python3 viewer.py --search "git"

# Find all sudo commands
python3 viewer.py --search "sudo"

# Find specific error messages
python3 viewer.py --search "error"

# Search only in clean logs
python3 viewer.py --search "git commit" --type clean

# Search only in raw logs
python3 viewer.py --search "error" --type raw
```

### Direct Log Access

```bash
# View a specific log file
python3 viewer.py --show 20240115-143022-12345.log

# Show last 50 lines of a log
python3 viewer.py --show 20240115-143022-12345.log --tail 50

# Use standard tools
cat ~/ttylogs/raw/20240115-143022-12345.log
cat ~/ttylogs/clean/20240115-143022-12345.log
grep "git commit" ~/ttylogs/clean/*.log
less ~/ttylogs/clean/20240115-143022-12345.log
```

### Data Analysis

Since logs are plain text, you can use any standard tools:

```bash
# Count how many times you used each command (clean logs)
grep -h "^[^[:space:]]*@[^[:space:]]*:" ~/ttylogs/clean/*.log | cut -d' ' -f2- | sort | uniq -c | sort -nr

# Find all file operations (clean logs)
grep -i "ls\|cp\|mv\|rm\|mkdir" ~/ttylogs/clean/*.log

# Search for specific patterns across all logs
grep -r "error\|failed\|exception" ~/ttylogs/

# Find when you last used a specific command
grep -h "git commit" ~/ttylogs/clean/*.log | tail -5

# Compare raw vs clean logs
wc -l ~/ttylogs/raw/*.log ~/ttylogs/clean/*.log
```

## File Structure

```
terminal-logger/
├── README.md                 # This file
├── install.sh               # Installation script
├── setup-bashrc.sh          # Bashrc integration script
├── terminal-wrapper.sh       # Terminal wrapper script
├── clean-logs.sh            # Clean logs processing script
├── uninstall.sh             # Uninstall script
├── wipe_logs.sh             # Log cleanup script
├── config.conf              # Default configuration
└── viewer.py               # Log viewing tool

~/ttylogs/                   # Log directory
├── raw/                     # Raw logs (with control sequences)
│   └── 20240115-143022-12345.log
└── clean/                   # Clean logs (readable)
    └── 20240115-143022-12345.log
```

## Security

- Logs are stored in `~/ttylogs/` with 700 permissions (user-only access)
- Each user has their own log directory
- **⚠️ CRITICAL WARNING**: Logs capture EVERYTHING including passwords, API keys, personal data, and sensitive information
- **⚠️ SECURITY RISK**: Anyone with access to your log files can see all your terminal activity
- **⚠️ DATA EXPOSURE**: Log files may contain confidential information that should never be shared
- No root access required - runs as regular user

## Troubleshooting

### No Logs Being Created

```bash
# Check if bashrc was modified
grep -A 5 -B 5 "SCRIPT_RUNNING" ~/.bashrc

# Check if log directory exists
ls -la ~/ttylogs/

# Reload bashrc
source ~/.bashrc

# Check if script command is available
which script
```

### Multiple Logging Instances

```bash
# Check if SCRIPT_RUNNING is set
echo $SCRIPT_RUNNING

# If you see multiple instances, restart terminal
# The SCRIPT_RUNNING variable prevents this
```

### Permission Issues

```bash
# Fix log directory permissions
chmod 700 ~/ttylogs

# Check bashrc permissions
ls -la ~/.bashrc
```

## Uninstallation

### Easy Uninstall

```bash
# Use the uninstall script (recommended)
./uninstall.sh
```

This will:
- Remove logging code from ~/.bashrc
- Remove configuration file ~/.terminal-logger.conf
- Remove wrapper and clean scripts
- **Keep your log files** (they remain untouched)

### Manual Uninstall

```bash
# Remove the terminal logger section from bashrc
# Edit ~/.bashrc and remove everything between:
# "# Terminal Logger - Simple Version" and "fi"

# Remove config file (optional)
rm ~/.terminal-logger.conf

# Remove logs (optional)
rm -rf ~/ttylogs
```

## Log Management

### Wipe All Logs

```bash
# Delete all log files (with confirmation)
./wipe_logs.sh
```

This will:
- Show you how many files will be deleted
- Ask for confirmation (y/N)
- Delete all raw and clean logs
- **Keep terminal logging active**

### Manual Log Cleanup

```bash
# Delete specific log files
rm ~/ttylogs/raw/old-session.log
rm ~/ttylogs/clean/old-session.log

# Delete all logs manually
rm -rf ~/ttylogs/raw/*.log
rm -rf ~/ttylogs/clean/*.log
```

## Requirements

- Linux system (any distribution)
- Python 3.6+ (for viewer tool)
- Bash shell
- `script` command (usually pre-installed)

## Disclaimer

**THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.**

**USE AT YOUR OWN RISK. THE AUTHORS ARE NOT RESPONSIBLE FOR ANY DATA LOSS, SECURITY BREACHES, SYSTEM DAMAGE, OR ANY OTHER ISSUES THAT MAY ARISE FROM USING THIS SOFTWARE.**

## License

MIT License - feel free to use and modify for your needs.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Support

- Create an issue for bugs or feature requests
- Check the troubleshooting section above
- Review the configuration options
