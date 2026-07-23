# SSH Setup Guide

GitHub Daily Activity uses SSH for secure Git operations.

## Why SSH?

- **Security**: No passwords or tokens stored
- **Convenience**: Set up once, use forever
- **Industry Standard**: Best practice for Git authentication

## Prerequisites

- GitHub account
- Terminal access
- `ssh` and `ssh-keygen` installed

## Step 1: Generate SSH Key

```bash
# Generate new SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"

# Or use RSA (less secure but wider compatibility)
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

When prompted:
- Press Enter to accept default location
- Enter a passphrase (recommended) or leave empty

## Step 2: Start SSH Agent

```bash
# Start ssh-agent
eval "$(ssh-agent -s)"

# Add your key
ssh-add ~/.ssh/id_ed25519
```

## Step 3: Copy Public Key

```bash
# Display public key
cat ~/.ssh/id_ed25519.pub

# Copy output to clipboard
```

## Step 4: Add to GitHub

1. Go to [GitHub Settings](https://github.com/settings/keys)
2. Click "New SSH key"
3. Paste your public key
4. Give it a descriptive name
5. Click "Add SSH key"

## Step 5: Test Connection

```bash
ssh -T git@github.com
```

Expected output:
```
Hi username! You've successfully authenticated, but GitHub does not provide shell access.
```

## Troubleshooting

### Connection Refused

```bash
# Test SSH connectivity
ssh -vT git@github.com

# Check if SSH is running
sudo systemctl status ssh
```

### Permission Denied

```bash
# Check key permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub

# Restart ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### Wrong Key

```bash
# List loaded keys
ssh-add -l

# Remove all keys
ssh-add -D

# Add specific key
ssh-add ~/.ssh/id_ed25519
```

## Multiple SSH Keys

If you have multiple GitHub accounts:

### Create SSH Config

```bash
nano ~/.ssh/config
```

Add:
```
# Work account
Host github.com-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work

# Personal account
Host github.com-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
```

### Use Specific Host

```bash
# Clone with specific account
git clone git@github.com-work:user/repo.git
```

## Security Best Practices

1. **Use a passphrase**: Protects your key if compromised
2. **Use ed25519**: More secure than RSA
3. **Don't share keys**: Each device should have its own
4. **Regular rotation**: Change keys periodically
5. **Use ssh-agent**: Avoids entering passphrase repeatedly

## Verification Script

```bash
#!/bin/bash
# Save as test-ssh.sh

echo "Testing SSH connection to GitHub..."
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "✓ SSH connection successful!"
else
    echo "✗ SSH connection failed!"
    echo "Please check your SSH configuration."
    exit 1
fi
```
