# Development Guide

Guide for developers contributing to GitHub Daily Activity.

## Development Environment

### Prerequisites

- Bash 4.0+
- ShellCheck
- Git
- SSH key for GitHub
- Linux system (Ubuntu/Debian recommended)

### Setup

```bash
# Clone repository
git clone https://github.com/SamanQasempour/github-daily-activity.git
cd github-daily-activity

# Make scripts executable
chmod +x boot-log.sh install.sh uninstall.sh

# Install ShellCheck (if not installed)
sudo apt install shellcheck
```

## Code Structure

### Main Script: boot-log.sh

The main script is organized into sections:

1. **Global Variables**: Constants and defaults
2. **Color Codes**: Terminal colors
3. **Configuration**: Default settings
4. **Logging Functions**: Log message utilities
5. **Utility Functions**: Helper functions
6. **System Info**: Data collection functions
7. **Boot Entry**: Entry generation
8. **Git Functions**: Git operations
9. **Validation**: Repository checks
10. **Status/Version**: Display functions
11. **Argument Parsing**: CLI options
12. **Main**: Entry point

### Adding Features

1. Create a function for the feature
2. Add configuration option if needed
3. Update documentation
4. Test thoroughly
5. Submit PR

## Coding Standards

### Bash Best Practices

```bash
# Always use set -Eeuo pipefail
set -Eeuo pipefail

# Quote all variables
echo "${variable}"

# Use local for function variables
my_function() {
    local var="$1"
    # ...
}

# Use readonly for constants
readonly CONSTANT="value"

# Use command -v instead of which
command -v git

# Handle errors
if ! command; then
    handle_error
fi
```

### Naming Conventions

- **Scripts**: lowercase with hyphens (`boot-log.sh`)
- **Variables**: lowercase with underscores (`boot_time`)
- **Constants**: uppercase with underscores (`SCRIPT_NAME`)
- **Functions**: lowercase with underscores (`get_system_info`)

### Comments

```bash
# Function description
# Parameters:
#   $1 - First parameter
#   $2 - Second parameter
# Returns:
#   0 - Success
#   1 - Failure
function_name() {
    # Implementation
}
```

## Testing

### Manual Testing

```bash
# Dry run
sudo ./boot-log.sh --dry-run

# Debug mode
sudo ./boot-log.sh --debug

# Status check
sudo ./boot-log.sh --status
```

### ShellCheck

```bash
# Check single file
shellcheck -s bash boot-log.sh

# Check all files
shellcheck -s bash *.sh

# Strict mode
shellcheck -s bash -S warning boot-log.sh
```

See [TESTING.md](TESTING.md) for comprehensive testing guide.

## Git Workflow

### Branches

- `main`: Stable release
- `develop`: Development branch
- `feature/*`: Feature branches
- `bugfix/*`: Bug fix branches

### Commits

Follow conventional commits:

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance

### Pull Request Process

1. Create feature branch
2. Make changes
3. Run ShellCheck
4. Test on supported systems
5. Update documentation
6. Submit PR
7. Wait for review

## Debugging

### Enable Debug Mode

```bash
sudo ./boot-log.sh --debug
```

### Check Logs

```bash
# Activity log
tail -f /opt/github-daily-activity/activity.log

# Error log
tail -f /opt/github-daily-activity/error.log

# System logs
journalctl -u github-daily-activity -f
```

### Common Issues

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

## Release Process

See [RELEASE.md](RELEASE.md)

## Questions?

Open an issue or contact: samann1389@gmail.com
