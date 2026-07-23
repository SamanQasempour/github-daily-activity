# Configuration Guide

GitHub Daily Activity uses a configuration file for customization.

## Configuration File

Location: `/opt/github-daily-activity/config.conf`

## Configuration Options

### Retry Settings

```bash
# Retry interval in seconds when internet is unavailable
# Default: 1800 (30 minutes)
RETRY_INTERVAL=1800
```

### Feature Toggles

```bash
# Enable/disable public IP detection
# Options: true, false
ENABLE_PUBLIC_IP=true

# Enable/disable git pull before commit
# Options: true, false
ENABLE_PULL=true

# Enable/disable git push after commit
# Options: true, false
ENABLE_PUSH=true

# Enable/disable git commit
# Options: true, false
ENABLE_COMMIT=true
```

### Logging Settings

```bash
# Log level for activity.log
# Options: DEBUG, INFO, WARN, ERROR
LOG_LEVEL=INFO
```

### Git Settings

```bash
# Branch detection mode
# Options: AUTO (detect main/master automatically), main, master
BRANCH=AUTO

# Repository path (leave empty for auto-detection from script location)
REPO_PATH=""
```

### History Settings

```bash
# Name of the history file
HISTORY_FILE="history.log"
```

### Network Settings

```bash
# Host to ping for internet connectivity check
PING_HOST="github.com"

# Ping timeout in seconds
PING_TIMEOUT=5

# Number of ping attempts
PING_ATTEMPTS=3
```

### Display Settings

```bash
# Enable colored output
# Options: true, false
ENABLE_COLORS=true

# Enable verbose output
# Options: true, false
VERBOSE=false
```

## Configuration Examples

### Minimal Configuration

```bash
RETRY_INTERVAL=1800
ENABLE_PUSH=true
LOG_LEVEL=INFO
```

### Maximum Features

```bash
RETRY_INTERVAL=900
ENABLE_PUBLIC_IP=true
ENABLE_PULL=true
ENABLE_PUSH=true
ENABLE_COMMIT=true
LOG_LEVEL=DEBUG
BRANCH=AUTO
ENABLE_COLORS=true
VERBOSE=true
```

### Privacy-Focused

```bash
ENABLE_PUBLIC_IP=false
ENABLE_PUSH=true
LOG_LEVEL=INFO
```

## Changing Configuration

1. Edit the configuration file:
   ```bash
   sudo nano /opt/github-daily-activity/config.conf
   ```

2. Restart the service:
   ```bash
   sudo systemctl restart github-daily-activity
   ```

3. Test with new configuration:
   ```bash
   sudo /opt/github-daily-activity/boot-log.sh --dry-run
   ```
