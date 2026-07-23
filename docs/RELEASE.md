# Release Process

Guide for releasing new versions of GitHub Daily Activity.

## Version Numbering

Follow Semantic Versioning:

- **Major (X.0.0)**: Breaking changes
- **Minor (0.X.0)**: New features, backward compatible
- **Patch (0.0.X)**: Bug fixes, backward compatible

## Release Checklist

### Pre-release

- [ ] All tests pass
- [ ] ShellCheck passes with no warnings
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version number updated in scripts

### Release

- [ ] Create release branch
- [ ] Update version numbers
- [ ] Create git tag
- [ ] Push to GitHub
- [ ] Create GitHub Release
- [ ] Update README if needed

### Post-release

- [ ] Verify release on GitHub
- [ ] Test installation from release
- [ ] Announce release (if major)

## Step-by-Step Process

### 1. Update Version

Update version in `boot-log.sh`:

```bash
readonly SCRIPT_VERSION="1.1.0"
readonly SCRIPT_DATE="2024-02-01"
```

### 2. Update CHANGELOG

Add new version to `CHANGELOG.md`:

```markdown
## [1.1.0] - 2024-02-01

### Added
- Feature 1
- Feature 2

### Fixed
- Bug fix 1

### Changed
- Change 1
```

### 3. Create Release Branch

```bash
git checkout -b release/1.1.0
```

### 4. Run Tests

```bash
# ShellCheck
shellcheck -s bash boot-log.sh install.sh uninstall.sh

# Dry run
sudo ./boot-log.sh --dry-run

# Full test
sudo ./boot-log.sh
```

### 5. Commit Changes

```bash
git add .
git commit -m "chore: prepare release 1.1.0"
```

### 6. Merge to Main

```bash
git checkout main
git merge release/1.1.0
git push origin main
```

### 7. Create Tag

```bash
git tag -a v1.1.0 -m "Release 1.1.0"
git push origin v1.1.0
```

### 8. Create GitHub Release

1. Go to GitHub Releases
2. Click "Create a new release"
3. Select tag `v1.1.0`
4. Add release notes from CHANGELOG
5. Publish release

### 9. Clean Up

```bash
git branch -d release/1.1.0
git push origin --delete release/1.1.0
```

## Release Notes Template

```markdown
# Release X.Y.Z

## What's New

- Feature 1: Description
- Feature 2: Description

## Bug Fixes

- Fix 1: Description
- Fix 2: Description

## Breaking Changes

- Change 1: Description and migration guide

## Installation

```bash
git clone https://github.com/SamanQasempour/github-daily-activity.git
cd github-daily-activity
sudo ./install.sh
```

## Upgrade

```bash
cd /opt/github-daily-activity
sudo git pull origin main
sudo systemctl restart github-daily-activity
```

## Contributors

- @contributor1
- @contributor2
```

## Hotfix Process

For critical bugs:

1. Create hotfix branch from main
2. Fix the bug
3. Test thoroughly
4. Merge to main
5. Create patch release
6. Tag and release

## Post-Release Verification

```bash
# Test fresh installation
cd /tmp
git clone https://github.com/SamanQasempour/github-daily-activity.git
cd github-daily-activity
sudo ./install.sh

# Verify service
sudo systemctl status github-daily-activity

# Run dry run
sudo ./boot-log.sh --dry-run
```
