# Logging System

GitHub Daily Activity uses three log files for different purposes.

## Log Files

### activity.log

**Purpose:** Normal operations and status messages

**Content:**
- Boot detection events
- System information collection
- Git operations (pull, commit, push)
- Configuration loading
- Success messages

**Example:**
```
[2024-01-15 09:30:45] [INFO] Starting boot activity recording...
[2024-01-15 09:30:45] [DEBUG] Configuration loaded from config.conf
[2024-01-15 09:30:45] [DEBUG] SSH authentication successful
[2024-01-15 09:30:45] [INFO] Internet connection established
[2024-01-15 09:30:45] [INFO] Pulling latest changes from main...
[2024-01-15 09:30:45] [INFO] Git pull successful
[2024-01-15 09:30:45] [INFO] Boot entry appended to history.log
[2024-01-15 09:30:45] [INFO] Committing changes: Boot Activity - 2024-01-15 09:30:45
[2024-01-15 09:30:45] [INFO] Git push successful
[2024-01-15 09:30:45] [INFO] Boot activity recording completed successfully
```

### error.log

**Purpose:** Error messages and failure details

**Content:**
- SSH authentication failures
- Network connection issues
- Git operation failures
- Repository validation errors
- Dependency missing errors

**Example:**
```
[2024-01-15 09:30:45] [ERROR] SSH authentication failed: Permission denied (publickey)
[2024-01-15 09:30:45] [ERROR] Git pull failed: Could not resolve host: github.com
[2024-01-15 09:30:45] [ERROR] Git push failed after 3 attempts
```

### system.log

**Purpose:** System events and lifecycle information

**Content:**
- Service start/stop events
- Boot activity lifecycle
- System state changes

**Example:**
```
[2024-01-15 09:30:45] [SYSTEM] Boot activity started
[2024-01-15 09:30:45] [SYSTEM] Boot activity completed successfully
```

## Log Format

All log entries follow this format:

```
[YYYY-MM-DD HH:MM:SS] [LEVEL] Message
```

### Log Levels

| Level | Description |
|-------|-------------|
| DEBUG | Detailed information for debugging |
| INFO | Normal operation messages |
| WARN | Warning messages (non-critical) |
| ERROR | Error messages (failures) |

## Configuring Logging

In `config.conf`:

```bash
# Set log level (DEBUG, INFO, WARN, ERROR)
LOG_LEVEL=INFO
```

### Log Level Effects

| Level | activity.log | console output |
|-------|--------------|----------------|
| DEBUG | All messages | All messages |
| INFO | INFO, WARN, ERROR | INFO, WARN, ERROR |
| WARN | WARN, ERROR | WARN, ERROR |
| ERROR | ERROR only | ERROR only |

## Viewing Logs

### Activity Log

```bash
# View entire log
cat /opt/github-daily-activity/activity.log

# View last 50 lines
tail -50 /opt/github-daily-activity/activity.log

# Search for errors
grep ERROR /opt/github-daily-activity/activity.log

# Follow in real-time
tail -f /opt/github-daily-activity/activity.log
```

### Error Log

```bash
# View errors
cat /opt/github-daily-activity/error.log

# View recent errors
tail -20 /opt/github-daily-activity/error.log
```

### System Logs (journalctl)

```bash
# View systemd logs
journalctl -u github-daily-activity

# Follow logs
journalctl -u github-daily-activity -f

# View since last boot
journalctl -u github-daily-activity -b
```

## Log Rotation

Logs are not automatically rotated. For long-term use, consider:

```bash
# Add to crontab
0 0 * * * /usr/sbin/logrotate /etc/logrotate.d/github-daily-activity
```

Create `/etc/logrotate.d/github-daily-activity`:

```
/opt/github-daily-activity/*.log {
    daily
    missingok
    rotate 7
    compress
    notifempty
}
```
