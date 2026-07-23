# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

### Added
- Initial release
- Automatic boot detection
- System information collection
- SSH-based GitHub authentication
- Internet retry system
- Systemd service integration
- Auto branch detection (main/master)
- Safe git operations with retry
- Comprehensive logging (activity, error, system)
- Multiple command modes (status, debug, version, dry-run)
- Configuration file support
- Installation and uninstallation scripts
- Complete documentation
- ShellCheck CI workflow
- GitHub issue and PR templates
- Code of Conduct
- Security policy

### Features
- Boot time detection using `who -b`
- Hostname, username, OS, kernel, architecture collection
- CPU, RAM, IP address, timezone, uptime collection
- Public IP detection with fallback to local IP
- Configurable retry interval (default: 30 minutes)
- Colored terminal output
- Debug mode with verbose logging
- Dry-run mode for testing
- Automatic repository validation
- Git pull before push
- Push retry mechanism (3 attempts)
- Error logging with timestamps
- System event logging

### Supported Systems
- Ubuntu 22.04+
- Ubuntu 24.04+
- Debian 11+
- Linux Mint 21+
- Pop!_OS 22.04+
