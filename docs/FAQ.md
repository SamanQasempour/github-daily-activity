# Frequently Asked Questions

## General

### What is GitHub Daily Activity?

GitHub Daily Activity is a Linux automation tool that automatically records system boots and creates GitHub contributions by committing and pushing boot history.

### Is it safe to use?

Yes! The tool:
- Only uses SSH for authentication (no passwords)
- Doesn't collect personal information
- Only writes to your own repository
- Can be disabled at any time

### Does it work on other operating systems?

Currently, it supports:
- Ubuntu 22.04+
- Ubuntu 24.04+
- Debian 11+
- Linux Mint 21+
- Pop!_OS 22.04+

### Can I contribute?

Absolutely! See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

## Installation

### Do I need root access?

Yes, for installation and systemd service management. The script runs as root to:
- Install to `/opt/`
- Create systemd service
- Manage service lifecycle

### What if I don't have SSH keys?

Generate them:
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
# Add to GitHub
```

### Can I install to a custom location?

Yes, edit the install script or copy files manually:
```bash
sudo cp boot-log.sh config.conf /your/custom/path/
```

## Usage

### How do I check if it's working?

```bash
# Check service status
sudo systemctl status github-daily-activity

# View boot history
cat /opt/github-daily-activity/history.log

# Run manually
sudo /opt/github-daily-activity/boot-log.sh --dry-run
```

### What happens if internet is down?

The script waits for internet availability with configurable retry interval (default: 30 minutes). Your boot data is saved locally and pushed when connection is restored.

### Can I customize what information is collected?

Yes! Edit `/opt/github-daily-activity/config.conf`:
```bash
ENABLE_PUBLIC_IP=false  # Disable IP collection
BRANCH=main             # Use specific branch
```

### How do I view my boot history?

```bash
cat /opt/github-daily-activity/history.log
```

## Troubleshooting

### The service isn't running

```bash
# Check status
sudo systemctl status github-daily-activity

# Check logs
journalctl -u github-daily-activity

# Restart
sudo systemctl restart github-daily-activity
```

### SSH authentication fails

```bash
# Test SSH
ssh -T git@github.com

# Check key
ssh-add -l

# Regenerate if needed
ssh-keygen -t ed25519 -C "your_email@example.com"
```

### Git push fails

```bash
# Check remote
cd /opt/github-daily-activity
git remote -v

# Manual push
git push origin main
```

## Configuration

### How do I change the retry interval?

Edit `/opt/github-daily-activity/config.conf`:
```bash
RETRY_INTERVAL=900  # 15 minutes
```

### Can I disable public IP detection?

Yes:
```bash
ENABLE_PUBLIC_IP=false
```

### How do I enable debug mode?

```bash
sudo /opt/github-daily-activity/boot-log.sh --debug
```

## Uninstallation

### How do I uninstall?

```bash
sudo ./uninstall.sh
```

Or manually:
```bash
sudo systemctl stop github-daily-activity
sudo systemctl disable github-daily-activity
sudo rm /etc/systemd/system/github-daily-activity.service
sudo rm -rf /opt/github-daily-activity
```

### Will it delete my repository?

No! The uninstaller only removes installed files. Your git repository remains intact.

## Support

### Where can I get help?

- Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- Open an [issue](https://github.com/SamanQasempour/github-daily-activity/issues)
- Contact: samann1389@gmail.com
