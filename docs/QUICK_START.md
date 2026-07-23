# Quick Start

Get GitHub Daily Activity running in 5 minutes!

## Step 1: Clone and Install

```bash
git clone https://github.com/SamanQasempour/github-daily-activity.git
cd github-daily-activity
chmod +x install.sh
sudo ./install.sh
```

## Step 2: Verify SSH

```bash
ssh -T git@github.com
# Expected: "Hi username! You've successfully authenticated..."
```

## Step 3: Test

```bash
# Preview what will be recorded
sudo /opt/github-daily-activity/boot-log.sh --dry-run

# Run manually
sudo /opt/github-daily-activity/boot-log.sh
```

## Step 4: Check Status

```bash
sudo /opt/github-daily-activity/boot-log.sh --status
```

## That's It!

The service will now run automatically on every boot.

## Quick Commands

| Command | Description |
|---------|-------------|
| `sudo systemctl status github-daily-activity` | Check service status |
| `sudo systemctl restart github-daily-activity` | Restart service |
| `sudo /opt/github-daily-activity/boot-log.sh --status` | Show detailed status |
| `sudo /opt/github-daily-activity/boot-log.sh --debug` | Run with debug output |
| `cat /opt/github-daily-activity/history.log` | View boot history |

## What Happens on Boot?

1. System boots
2. systemd starts the service
3. Script detects boot time
4. Collects system information
5. Appends to history.log
6. Waits for internet
7. Pulls latest changes
8. Commits and pushes
9. GitHub shows your contribution!

## Next Steps

- Read [Configuration](CONFIGURATION.md) to customize behavior
- Read [How It Works](HOW_IT_WORKS.md) to understand the process
- Read [Troubleshooting](TROUBLESHOOTING.md) if you encounter issues
