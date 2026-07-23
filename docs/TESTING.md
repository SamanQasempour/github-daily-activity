# Testing Guide

Comprehensive testing procedures for GitHub Daily Activity.

## Testing Levels

### 1. Unit Testing

Test individual functions:

```bash
# Test system info functions
source boot-log.sh

# Test each function
get_boot_time
get_hostname
get_username
get_os
get_kernel
get_architecture
get_cpu
get_ram
get_ip_address
get_timezone
get_uptime
```

### 2. Integration Testing

Test script execution:

```bash
# Dry run (no changes)
sudo ./boot-log.sh --dry-run

# Debug mode
sudo ./boot-log.sh --debug

# Full run
sudo ./boot-log.sh
```

### 3. Service Testing

Test systemd integration:

```bash
# Check service status
sudo systemctl status github-daily-activity

# Start service
sudo systemctl start github-daily-activity

# Check logs
journalctl -u github-daily-activity
```

## Test Cases

### SSH Authentication

```bash
# Test SSH connection
ssh -T git@github.com

# Expected: "Hi username! You've successfully authenticated..."
```

### Internet Connectivity

```bash
# Test ping
ping -c 3 github.com

# Expected: Successful ping responses
```

### Git Operations

```bash
# Test git operations
cd /opt/github-daily-activity
git status
git pull origin main
git add .
git status  # Check for changes
git commit -m "Test commit"
git push origin main
```

### System Information

```bash
# Test all system info commands
who -b
hostname
whoami
cat /etc/os-release
uname -r
uname -m
grep "model name" /proc/cpuinfo
free -h
curl -s ifconfig.me
timedatectl
uptime -p
```

## Automated Testing

### Test Script

Create `test.sh`:

```bash
#!/bin/bash
set -euo pipefail

echo "Running tests..."

# Test 1: Check dependencies
echo "Test 1: Checking dependencies..."
for cmd in git ssh ping who hostnamectl; do
    if ! command -v "${cmd}" &>/dev/null; then
        echo "FAIL: Missing ${cmd}"
        exit 1
    fi
done
echo "PASS: All dependencies found"

# Test 2: Check SSH
echo "Test 2: Checking SSH..."
if ! ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "FAIL: SSH authentication failed"
    exit 1
fi
echo "PASS: SSH authentication successful"

# Test 3: Check internet
echo "Test 3: Checking internet..."
if ! ping -c 1 github.com &>/dev/null; then
    echo "FAIL: No internet connection"
    exit 1
fi
echo "PASS: Internet connection available"

# Test 4: Check repository
echo "Test 4: Checking repository..."
if [[ ! -d .git ]]; then
    echo "FAIL: Not a git repository"
    exit 1
fi
echo "PASS: Valid git repository"

# Test 5: Dry run
echo "Test 5: Running dry run..."
if ! sudo ./boot-log.sh --dry-run; then
    echo "FAIL: Dry run failed"
    exit 1
fi
echo "PASS: Dry run successful"

echo ""
echo "All tests passed!"
```

### Run Tests

```bash
chmod +x test.sh
./test.sh
```

## Platform Testing

Test on all supported systems:

| System | Tested |
|--------|--------|
| Ubuntu 22.04 | Required |
| Ubuntu 24.04 | Required |
| Debian 11 | Required |
| Debian 12 | Required |
| Linux Mint 21 | Required |
| Pop!_OS 22.04 | Required |

### Virtual Machine Testing

```bash
# Create VM with each system
# Install dependencies
# Run test suite
# Verify results
```

## Performance Testing

### Boot Time Impact

Measure system boot time with and without service:

```bash
# Without service
systemd-analyze

# With service
systemd-analyze
systemd-analyze blame | grep github
```

### Network Usage

Monitor network traffic:

```bash
# Install monitoring tool
sudo apt install iftop

# Monitor traffic during boot
sudo iftop -i eth0
```

## Security Testing

### SSH Key Security

```bash
# Check key permissions
ls -la ~/.ssh/

# Expected:
# drwx------ 2 user user 4096 .
# -rw------- 1 user user  419 id_ed25519
# -rw-r--r-- 1 user user  100 id_ed25519.pub
```

### File Permissions

```bash
# Check installation permissions
ls -la /opt/github-daily-activity/

# Expected: Scripts executable, logs readable
```

## Test Documentation

Document test results:

| Test | Date | System | Result |
|------|------|--------|--------|
| SSH Auth | 2024-01-15 | Ubuntu 22.04 | PASS |
| Dry Run | 2024-01-15 | Ubuntu 22.04 | PASS |
| Service | 2024-01-15 | Ubuntu 22.04 | PASS |

## Continuous Testing

GitHub Actions runs ShellCheck on every push. See `.github/workflows/shellcheck.yml`.

For manual testing, run the test suite before each release.
