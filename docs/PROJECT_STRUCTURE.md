# Project Structure

## Directory Layout

```
github-daily-activity/
├── README.md                    # Project documentation
├── LICENSE                      # MIT License
├── CHANGELOG.md                 # Version history
├── CONTRIBUTING.md              # Contribution guidelines
├── SECURITY.md                  # Security policy
├── install.sh                   # Installation script
├── uninstall.sh                 # Uninstallation script
├── boot-log.sh                  # Main boot logging script
├── config.conf                  # Configuration file
├── .gitignore                   # Git ignore rules
├── systemd/
│   └── github-daily-activity.service
├── docs/
│   ├── INDEX.md                 # Documentation index
│   ├── INSTALL.md               # Installation guide
│   ├── QUICK_START.md           # Quick start guide
│   ├── CONFIGURATION.md         # Configuration options
│   ├── HOW_IT_WORKS.md          # Technical overview
│   ├── SYSTEMD.md               # Service management
│   ├── PROJECT_STRUCTURE.md     # This file
│   ├── LOGGING.md               # Log files explained
│   ├── TROUBLESHOOTING.md       # Common issues
│   ├── SSH_SETUP.md             # SSH configuration
│   ├── FAQ.md                   # Frequently asked questions
│   ├── KNOWLEDGE_BASE.md        # Deep dive
│   ├── DEVELOPMENT.md           # Development guide
│   ├── TESTING.md               # Testing procedures
│   ├── RELEASE.md               # Release process
│   └── ROADMAP.md               # Future plans
└── .github/
    ├── workflows/
    │   └── shellcheck.yml       # CI workflow
    ├── ISSUE_TEMPLATE/
    │   ├── bug_report.md        # Bug report template
    │   └── feature_request.md   # Feature request template
    ├── PULL_REQUEST_TEMPLATE.md # PR template
    └── CODE_OF_CONDUCT.md       # Code of conduct
```

## File Descriptions

### Core Files

| File | Description |
|------|-------------|
| `boot-log.sh` | Main script that runs on boot |
| `install.sh` | Automated installation script |
| `uninstall.sh` | Automated uninstallation script |
| `config.conf` | User configuration file |

### Runtime Files (Created by script)

| File | Description |
|------|-------------|
| `history.log` | Boot history records |
| `activity.log` | Normal operation logs |
| `error.log` | Error messages |
| `system.log` | System events |

### Service Files

| File | Description |
|------|-------------|
| `systemd/github-daily-activity.service` | Systemd service definition |

### Documentation

| File | Description |
|------|-------------|
| `README.md` | Main documentation |
| `docs/` | Detailed documentation directory |
| `CONTRIBUTING.md` | Contribution guidelines |
| `SECURITY.md` | Security policy |
| `CHANGELOG.md` | Version history |

### GitHub Files

| File | Description |
|------|-------------|
| `.github/workflows/shellcheck.yml` | CI for code quality |
| `.github/ISSUE_TEMPLATE/` | Issue templates |
| `.github/PULL_REQUEST_TEMPLATE.md` | PR template |
| `.github/CODE_OF_CONDUCT.md` | Community guidelines |

## Installation Directory

After installation, files are placed in:

```
/opt/github-daily-activity/
├── boot-log.sh
├── config.conf
├── history.log
├── activity.log
├── error.log
└── system.log
```

## Systemd Directory

```
/etc/systemd/system/
└── github-daily-activity.service
```
