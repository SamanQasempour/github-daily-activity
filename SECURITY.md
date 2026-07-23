# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability, please report it responsibly.

**Do NOT open a public issue for security vulnerabilities.**

Instead, please email: samann1389@gmail.com

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

## Security Measures

### Authentication

- Uses SSH keys only (no passwords or tokens)
- Never stores credentials in files
- Validates SSH connection before push

### Data Privacy

- Does not collect personal information beyond system info
- IP address is optional (can be disabled)
- All data stays in your repository

### File Permissions

- Scripts require appropriate permissions
- Log files are created with restrictive permissions
- Configuration file should not contain secrets

### Network Security

- Uses HTTPS for public IP detection
- SSH for Git operations
- No outbound connections except to GitHub

## Best Practices

1. Keep your SSH keys secure
2. Use a dedicated GitHub account if needed
3. Review logs regularly
4. Update the tool regularly
5. Use strong SSH key passphrase

## Contact

For security concerns, contact: samann1389@gmail.com
