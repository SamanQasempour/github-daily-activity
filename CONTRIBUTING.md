# Contributing to GitHub Daily Activity

Thank you for your interest in contributing! This document provides guidelines and information for contributors.

## How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in [Issues](https://github.com/SamanQasempour/github-daily-activity/issues)
2. If not, create a new issue using the Bug Report template
3. Include as much detail as possible

### Suggesting Features

1. Check if the feature has already been suggested
2. Create a new issue using the Feature Request template
3. Explain why the feature would be useful

### Pull Requests

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Run ShellCheck: `shellcheck -s bash -x boot-log.sh install.sh uninstall.sh`
5. Test on supported systems
6. Commit your changes: `git commit -m 'Add amazing feature'`
7. Push to the branch: `git push origin feature/amazing-feature`
8. Open a Pull Request

## Development Setup

### Prerequisites

- Bash 4.0+
- ShellCheck
- Git
- SSH key configured for GitHub

### Local Development

```bash
# Clone the repository
git clone https://github.com/SamanQasempour/github-daily-activity.git
cd github-daily-activity

# Make scripts executable
chmod +x boot-log.sh install.sh uninstall.sh

# Test in dry-run mode
./boot-log.sh --dry-run

# Run ShellCheck
shellcheck -s bash boot-log.sh install.sh uninstall.sh
```

### Testing

See [docs/TESTING.md](docs/TESTING.md) for detailed testing procedures.

## Code Style

### Bash Best Practices

- Use `set -Eeuo pipefail` at the start of scripts
- Quote all variables: `"${variable}"`
- Use `readonly` for constants
- Use `local` for function variables
- Use `command -v` instead of `which`
- Handle errors gracefully
- Use meaningful variable names
- Add comments for complex logic

### ShellCheck

All scripts must pass ShellCheck without warnings:

```bash
shellcheck -s bash -S warning script.sh
```

### Naming Conventions

- Scripts: lowercase with hyphens (e.g., `boot-log.sh`)
- Variables: lowercase with underscores (e.g., `boot_time`)
- Constants: uppercase with underscores (e.g., `SCRIPT_NAME`)
- Functions: lowercase with underscores (e.g., `get_system_info`)

## Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor" not "Moves cursor")
- Keep the first line under 72 characters
- Reference issues and pull requests where relevant

Example:
```
Add support for Arch Linux

- Add Arch Linux detection in get_os()
- Update README with Arch Linux instructions
- Closes #42
```

## Pull Request Guidelines

- Fill out the PR template completely
- Include screenshots if applicable
- Update documentation if needed
- Add tests if applicable
- Ensure all checks pass

## Questions?

If you have questions, feel free to open an issue or contact the maintainer.
