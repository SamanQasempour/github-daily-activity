# Troubleshooting

Common issues and solutions.

## SSH Issues

### SSH Authentication Failed

**Symptom:**
```
[ERROR] SSH authentication failed
```

**Solution:**
```bash
# 1. Check if SSH key exists
ls -la ~/.ssh/

# 2. Test SSH connection
ssh -T git@github.com

# 3. If key doesn't exist, generate one
ssh-keygen -t ed25519 -C "your_email@example.com"

# 4. Add to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# 5. Add public key to GitHub
cat ~/.ssh/id_ed25519.pub
# Copy output to GitHub → Settings → SSH keys
```

### Permission Denied (publickey)

**Symptom:**
```
git@github.com: Permission denied (publickey).
```

**Solution:**
```bash
# Check SSH key permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub

# Restart ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

## Network Issues

### No Internet Connection

**Symptom:**
```
[WARN] No internet connection. Retrying in 1800 seconds...
```

**Solution:**
- Wait for internet to become available
- Check network settings
- Verify `RETRY_INTERVAL` in config.conf

### Cannot Resolve Host

**Symptom:**
```
[ERROR] Could not resolve host: github.com
```

**Solution:**
```bash
# Check DNS
nslookup github.com

# Test connectivity
ping github.com

# Check network interface
ip addr show
```

## Git Issues

### Not a Git Repository

**Symptom:**
```
[ERROR] Not a git repository
```

**Solution:**
```bash
# Check if .git exists
ls -la /opt/github-daily-activity/

# If missing, initialize
cd /opt/github-daily-activity
git init
git remote add origin git@github.com:SamanQasempour/github-daily-activity.git
git pull origin main
```

### Git Pull Failed

**Symptom:**
```
[ERROR] Git pull failed
```

**Solution:**
```bash
# Check remote
cd /opt/github-daily-activity
git remote -v

# Check branch
git branch -a

# Manual pull
git pull origin main
```

### Git Push Failed

**Symptom:**
```
[ERROR] Git push failed after 3 attempts
```

**Solution:**
```bash
# Check if you have push access
git push origin main

# Check remote URL
git remote get-url origin

# Ensure SSH key has write access
```

## Service Issues

### Service Won't Start

**Symptom:**
```bash
sudo systemctl status github-daily-activity
# Shows: inactive (dead)
```

**Solution:**
```bash
# Check for errors
journalctl -u github-daily-activity -n 50

# Check service file
systemctl cat github-daily-activity

# Verify script exists and is executable
ls -la /opt/github-daily-activity/boot-log.sh

# Reload and restart
sudo systemctl daemon-reload
sudo systemctl restart github-daily-activity
```

### Service Not Running on Boot

**Symptom:**
- Service is not active after boot

**Solution:**
```bash
# Check if enabled
systemctl is-enabled github-daily-activity

# Enable if not
sudo systemctl enable github-daily-activity

# Check network dependency
systemctl status network-online.target
```

## Permission Issues

### Permission Denied

**Symptom:**
```
[ERROR] Permission denied
```

**Solution:**
```bash
# Check file permissions
ls -la /opt/github-daily-activity/

# Fix permissions
sudo chmod +x /opt/github-daily-activity/boot-log.sh
sudo chown -R root:root /opt/github-daily-activity/

# Run as root
sudo /opt/github-daily-activity/boot-log.sh
```

## Log Issues

### Log Files Not Created

**Symptom:**
- Log files don't exist

**Solution:**
```bash
# Check directory permissions
ls -la /opt/github-daily-activity/

# Create log files manually
sudo touch /opt/github-daily-activity/{activity,error,system,history}.log
sudo chmod 644 /opt/github-daily-activity/*.log
```

## Debug Mode

Enable debug mode for detailed output:

```bash
sudo /opt/github-daily-activity/boot-log.sh --debug
```

This will show:
- Configuration loading
- Dependency checks
- SSH authentication details
- Network connectivity tests
- Git operations
- All system information collected
