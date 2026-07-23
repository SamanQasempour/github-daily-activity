# Installation Guide

## Prerequisites

Before installing GitHub Daily Activity, ensure you have:

### 1. SSH Key for GitHub

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"

# Start ssh-agent
eval "$(ssh-agent -s)"

# Add key to ssh-agent
ssh-add ~/.ssh/id_ed25519

# Copy public key
cat ~/.ssh/id_ed25519.pub

# Add to GitHub: Settings → SSH and GPG keys → New SSH key
```

### 2. Verify SSH Connection

```bash
ssh -T git@github.com
# Should display: "Hi username! You've successfully authenticated..."
```

### 3. Git Installed

```bash
# Check git version
git --version

# If not installed:
sudo apt install git
```

## Installation Methods

### Method 1: Using install.sh (Recommended)

```bash
# Clone the repository
git clone https://github.com/SamanQasempour/github-daily-activity.git

# Navigate to directory
cd github-daily-activity

# Make installer executable
chmod +x install.sh

# Run installer (requires root)
sudo ./install.sh
```

### Method 2: Manual Installation

```bash
# Create installation directory
sudo mkdir -p /opt/github-daily-activity

# Copy files
sudo cp boot-log.sh config.conf /opt/github-daily-activity/
sudo chmod +x /opt/github-daily-activity/boot-log.sh

# Create log files
sudo touch /opt/github-daily-activity/{activity,error,system,history}.log

# Copy service file
sudo cp systemd/github-daily-activity.service /etc/systemd/system/

# Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable github-daily-activity
sudo systemctl start github-daily-activity
```

## Post-Installation

### Verify Installation

```bash
# Check service status
sudo systemctl status github-daily-activity

# Test boot activity
sudo /opt/github-daily-activity/boot-log.sh --dry-run

# Run manually
sudo /opt/github-daily-activity/boot-log.sh
```

### Check Logs

```bash
# Activity log
cat /opt/github-daily-activity/activity.log

# Error log
cat /opt/github-daily-activity/error.log

# System logs
journalctl -u github-daily-activity
```

## Uninstallation

```bash
# Run uninstaller
sudo ./uninstall.sh
```

Or manually:

```bash
# Stop and disable service
sudo systemctl stop github-daily-activity
sudo systemctl disable github-daily-activity

# Remove service file
sudo rm /etc/systemd/system/github-daily-activity.service
sudo systemctl daemon-reload

# Remove installation directory
sudo rm -rf /opt/github-daily-activity
```

## Troubleshooting Installation

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues.
