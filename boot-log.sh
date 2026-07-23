#!/bin/bash
# ============================================================================
# GitHub Daily Activity - Boot Logger
# ============================================================================
# Description: Automatically records system boot and creates GitHub activity
# Author: SamanQasempour
# License: MIT
# Version: 1.0.0
# ============================================================================

set -Eeuo pipefail

# --------------------------------------------------------------------------
# Global Variables
# --------------------------------------------------------------------------
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_VERSION="1.0.0"
readonly SCRIPT_DATE="2024-01-01"

# --------------------------------------------------------------------------
# Color Codes
# --------------------------------------------------------------------------
if [[ -t 1 ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly CYAN='\033[0;36m'
    readonly BOLD='\033[1m'
    readonly NC='\033[0m'
else
    readonly RED=''
    readonly GREEN=''
    readonly YELLOW=''
    readonly BLUE=''
    readonly CYAN=''
    readonly BOLD=''
    readonly NC=''
fi

# --------------------------------------------------------------------------
# Default Configuration
# --------------------------------------------------------------------------
RETRY_INTERVAL=1800
ENABLE_PUBLIC_IP=true
ENABLE_PULL=true
ENABLE_PUSH=true
ENABLE_COMMIT=true
LOG_LEVEL="INFO"
BRANCH="AUTO"
REPO_PATH=""
HISTORY_FILE="history.log"
PING_HOST="github.com"
PING_TIMEOUT=5
PING_ATTEMPTS=3
ENABLE_COLORS=true
VERBOSE=false

# --------------------------------------------------------------------------
# Runtime Variables
# --------------------------------------------------------------------------
LOG_DIR=""
ACTIVITY_LOG=""
ERROR_LOG=""
SYSTEM_LOG=""

# --------------------------------------------------------------------------
# Load Configuration
# --------------------------------------------------------------------------
load_config() {
    local config_file="${SCRIPT_DIR}/config.conf"

    if [[ -f "${config_file}" ]]; then
        # shellcheck source=config.conf
        source "${config_file}"

        if [[ "${VERBOSE}" == "true" ]]; then
            echo -e "${CYAN}[INFO]${NC} Configuration loaded from ${config_file}"
        fi
    else
        echo -e "${YELLOW}[WARN]${NC} Config file not found: ${config_file}"
        echo -e "${YELLOW}[WARN]${NC} Using default configuration"
    fi

    # Set log directory and files
    LOG_DIR="${SCRIPT_DIR}"
    ACTIVITY_LOG="${LOG_DIR}/activity.log"
    ERROR_LOG="${LOG_DIR}/error.log"
    SYSTEM_LOG="${LOG_DIR}/system.log"

    # Override repo path if not set
    if [[ -z "${REPO_PATH}" ]]; then
        REPO_PATH="${SCRIPT_DIR}"
    fi
}

# --------------------------------------------------------------------------
# Logging Functions
# --------------------------------------------------------------------------
log_message() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

    # Check if we should log this level
    case "${LOG_LEVEL}" in
        DEBUG) ;;
        INFO)
            [[ "${level}" == "DEBUG" ]] && return 0
            ;;
        WARN)
            [[ "${level}" == "DEBUG" || "${level}" == "INFO" ]] && return 0
            ;;
        ERROR)
            [[ "${level}" != "ERROR" ]] && return 0
            ;;
        *)
            return 0
            ;;
    esac

    # Format output
    local color=""
    case "${level}" in
        DEBUG) color="${CYAN}" ;;
        INFO)  color="${GREEN}" ;;
        WARN)  color="${YELLOW}" ;;
        ERROR) color="${RED}" ;;
    esac

    # Write to activity log
    if [[ -n "${ACTIVITY_LOG}" ]]; then
        echo "[${timestamp}] [${level}] ${message}" >> "${ACTIVITY_LOG}" 2>/dev/null || true
    fi

    # Write to console if colors enabled
    if [[ "${ENABLE_COLORS}" == "true" ]]; then
        echo -e "${color}[${level}]${NC} ${message}"
    else
        echo "[${level}] ${message}"
    fi
}

log_error() {
    local message="$1"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

    # Write to error log
    if [[ -n "${ERROR_LOG}" ]]; then
        echo "[${timestamp}] [ERROR] ${message}" >> "${ERROR_LOG}" 2>/dev/null || true
    fi

    log_message "ERROR" "${message}"
}

log_system() {
    local message="$1"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

    # Write to system log
    if [[ -n "${SYSTEM_LOG}" ]]; then
        echo "[${timestamp}] [SYSTEM] ${message}" >> "${SYSTEM_LOG}" 2>/dev/null || true
    fi
}

# --------------------------------------------------------------------------
# Utility Functions
# --------------------------------------------------------------------------
command_exists() {
    command -v "$1" &>/dev/null
}

check_dependencies() {
    local missing_deps=()

    for cmd in git ssh ping who hostnamectl; do
        if ! command_exists "${cmd}"; then
            missing_deps+=("${cmd}")
        fi
    done

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        log_error "Please install: sudo apt install ${missing_deps[*]}"
        return 1
    fi

    return 0
}

check_ssh_auth() {
    log_message "DEBUG" "Checking SSH authentication..."

    local ssh_output
    if ssh_output=$(ssh -T git@github.com 2>&1); then
        log_message "DEBUG" "SSH authentication successful"
        return 0
    else
        local exit_code=$?
        # GitHub returns exit code 1 for successful auth but "Hi user!" message
        if [[ "${ssh_output}" == *"You've successfully authenticated"* ]]; then
            log_message "DEBUG" "SSH authentication successful"
            return 0
        fi
        log_error "SSH authentication failed: ${ssh_output}"
        return 1
    fi
}

wait_for_internet() {
    log_message "INFO" "Waiting for internet connection..."

    local attempt=1
    while true; do
        log_message "DEBUG" "Internet check attempt ${attempt}..."

        if ping -c "${PING_ATTEMPTS}" -W "${PING_TIMEOUT}" "${PING_HOST}" &>/dev/null; then
            log_message "INFO" "Internet connection established"
            return 0
        fi

        log_message "WARN" "No internet connection. Retrying in ${RETRY_INTERVAL} seconds..."
        sleep "${RETRY_INTERVAL}"
        ((attempt++))
    done
}

# --------------------------------------------------------------------------
# System Information Functions
# --------------------------------------------------------------------------
get_boot_time() {
    local boot_time
    boot_time=$(who -b 2>/dev/null | awk '{print $3 " " $4}' || echo "Unknown")
    if [[ "${boot_time}" == "Unknown" || -z "${boot_time}" ]]; then
        boot_time=$(date '+%Y-%m-%d %H:%M:%S')
    else
        boot_time=$(date -d "${boot_time}" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date '+%Y-%m-%d %H:%M:%S')
    fi
    echo "${boot_time}"
}

get_hostname() {
    hostname 2>/dev/null || echo "Unknown"
}

get_username() {
    whoami 2>/dev/null || echo "Unknown"
}

get_os() {
    local os="Unknown"
    if [[ -f /etc/os-release ]]; then
        os=$(source /etc/os-release 2>/dev/null && echo "${PRETTY_NAME}" || echo "Unknown")
    elif command_exists lsb_release; then
        os=$(lsb_release -ds 2>/dev/null || echo "Unknown")
    fi
    echo "${os}"
}

get_kernel() {
    uname -r 2>/dev/null || echo "Unknown"
}

get_architecture() {
    uname -m 2>/dev/null || echo "Unknown"
}

get_cpu() {
    local cpu="Unknown"
    if [[ -f /proc/cpuinfo ]]; then
        cpu=$(grep -m1 "model name" /proc/cpuinfo 2>/dev/null | cut -d: -f2 | xargs || echo "Unknown")
    fi
    if [[ "${cpu}" == "Unknown" && -f /proc/cpuinfo ]]; then
        cpu=$(grep -m1 "Hardware" /proc/cpuinfo 2>/dev/null | cut -d: -f2 | xargs || echo "Unknown")
    fi
    echo "${cpu}"
}

get_ram() {
    local ram="Unknown"
    if command_exists free; then
        ram=$(free -h 2>/dev/null | awk '/^Mem:/{print $2}' || echo "Unknown")
    fi
    echo "${ram}"
}

get_ip_address() {
    local ip="Unknown"
    if [[ "${ENABLE_PUBLIC_IP}" == "true" ]]; then
        # Try to get public IP
        ip=$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null || echo "")
        if [[ -z "${ip}" ]]; then
            ip=$(curl -s --max-time 5 https://ifconfig.me 2>/dev/null || echo "")
        fi
    fi

    if [[ -z "${ip}" || "${ip}" == "Unknown" ]]; then
        # Fallback to local IP
        ip=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "Unknown")
    fi

    echo "${ip}"
}

get_timezone() {
    timedatectl 2>/dev/null | grep "Time zone" | awk '{print $3}' || echo "Unknown"
}

get_uptime() {
    uptime -p 2>/dev/null || uptime | sed 's/.*up //' | sed 's/,.*//' || echo "Unknown"
}

get_git_branch() {
    local branch="Unknown"
    cd "${REPO_PATH}" 2>/dev/null || return 1

    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || echo "Unknown")
    echo "${branch}"
}

get_repo_path() {
    echo "${REPO_PATH}"
}

# --------------------------------------------------------------------------
# Boot Entry Functions
# --------------------------------------------------------------------------
generate_boot_entry() {
    local boot_time
    local hostname_val
    local username_val
    local os
    local kernel
    local arch
    local cpu
    local ram
    local ip
    local timezone
    local uptime_val
    local branch
    local repo

    boot_time=$(get_boot_time)
    hostname_val=$(get_hostname)
    username_val=$(get_username)
    os=$(get_os)
    kernel=$(get_kernel)
    arch=$(get_architecture)
    cpu=$(get_cpu)
    ram=$(get_ram)
    ip=$(get_ip_address)
    timezone=$(get_timezone)
    uptime_val=$(get_uptime)
    branch=$(get_git_branch)
    repo=$(get_repo_path)

    cat <<EOF
========================================
Boot Time:
${boot_time}

Hostname:
${hostname_val}

Username:
${username_val}

OS:
${os}

Kernel:
${kernel}

Architecture:
${arch}

CPU:
${cpu}

RAM:
${ram}

IP Address:
${ip}

Timezone:
${timezone}

Uptime:
${uptime_val}

Git Branch:
${branch}

Repository:
${repo}

========================================
EOF
}

append_boot_entry() {
    local entry
    entry=$(generate_boot_entry)

    echo "${entry}" >> "${SCRIPT_DIR}/${HISTORY_FILE}"
    log_message "INFO" "Boot entry appended to ${HISTORY_FILE}"
}

# --------------------------------------------------------------------------
# Git Functions
# --------------------------------------------------------------------------
detect_branch() {
    local branch=""

    cd "${REPO_PATH}" 2>/dev/null || {
        log_error "Cannot access repository: ${REPO_PATH}"
        return 1
    }

    if [[ "${BRANCH}" == "AUTO" ]]; then
        # Check if main branch exists
        if git show-ref --verify --quiet refs/heads/main 2>/dev/null; then
            branch="main"
        elif git show-ref --verify --quiet refs/heads/master 2>/dev/null; then
            branch="master"
        else
            # Try to detect from remote
            branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "")
            if [[ -z "${branch}" ]]; then
                branch="main"
                log_message "WARN" "Could not detect branch, defaulting to: ${branch}"
            fi
        fi
    else
        branch="${BRANCH}"
    fi

    log_message "DEBUG" "Detected branch: ${branch}"
    echo "${branch}"
}

git_pull_safely() {
    if [[ "${ENABLE_PULL}" != "true" ]]; then
        log_message "DEBUG" "Git pull disabled in configuration"
        return 0
    fi

    cd "${REPO_PATH}" 2>/dev/null || {
        log_error "Cannot access repository: ${REPO_PATH}"
        return 1
    }

    local branch
    branch=$(detect_branch)

    log_message "INFO" "Pulling latest changes from ${branch}..."

    if git pull origin "${branch}" 2>/dev/null; then
        log_message "INFO" "Git pull successful"
        return 0
    else
        log_error "Git pull failed"
        return 1
    fi
}

git_commit_and_push() {
    if [[ "${ENABLE_COMMIT}" != "true" ]]; then
        log_message "DEBUG" "Git commit disabled in configuration"
        return 0
    fi

    cd "${REPO_PATH}" 2>/dev/null || {
        log_error "Cannot access repository: ${REPO_PATH}"
        return 1
    }

    local branch
    branch=$(detect_branch)
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local commit_message="Boot Activity - ${timestamp}"

    # Stage changes
    log_message "INFO" "Staging changes..."
    if ! git add . 2>/dev/null; then
        log_error "Failed to stage changes"
        return 1
    fi

    # Check if there are changes to commit
    if git diff --cached --quiet 2>/dev/null; then
        log_message "INFO" "No changes to commit"
        return 0
    fi

    # Commit
    log_message "INFO" "Committing changes: ${commit_message}"
    if ! git commit -m "${commit_message}" 2>/dev/null; then
        log_error "Failed to commit changes"
        return 1
    fi

    # Push
    if [[ "${ENABLE_PUSH}" != "true" ]]; then
        log_message "DEBUG" "Git push disabled in configuration"
        return 0
    fi

    log_message "INFO" "Pushing to ${branch}..."
    local push_attempts=0
    local max_push_attempts=3

    while [[ ${push_attempts} -lt ${max_push_attempts} ]]; do
        if git push origin "${branch}" 2>/dev/null; then
            log_message "INFO" "Git push successful"
            return 0
        fi

        ((push_attempts++))
        if [[ ${push_attempts} -lt ${max_push_attempts} ]]; then
            log_message "WARN" "Push failed, retrying in 5 seconds... (${push_attempts}/${max_push_attempts})"
            sleep 5
        fi
    done

    log_error "Git push failed after ${max_push_attempts} attempts"
    return 1
}

# --------------------------------------------------------------------------
# Validation Functions
# --------------------------------------------------------------------------
validate_repository() {
    log_message "DEBUG" "Validating repository..."

    if [[ ! -d "${REPO_PATH}/.git" ]]; then
        log_error "Not a git repository: ${REPO_PATH}"
        return 1
    fi

    cd "${REPO_PATH}" 2>/dev/null || {
        log_error "Cannot access repository: ${REPO_PATH}"
        return 1
    }

    # Check remote
    if ! git remote -v 2>/dev/null | grep -q "github.com"; then
        log_error "Remote does not point to GitHub"
        return 1
    fi

    log_message "DEBUG" "Repository validation passed"
    return 0
}

# --------------------------------------------------------------------------
# Status and Version Functions
# --------------------------------------------------------------------------
show_status() {
    echo ""
    echo -e "${BOLD}========================================${NC}"
    echo -e "${BOLD}  GitHub Daily Activity - Status${NC}"
    echo -e "${BOLD}========================================${NC}"
    echo ""

    # Service status
    echo -e "${BOLD}Service Status:${NC}"
    if systemctl is-active github-daily-activity.service &>/dev/null; then
        echo -e "  Status: ${GREEN}Active${NC}"
    else
        echo -e "  Status: ${RED}Inactive${NC}"
    fi

    if systemctl is-enabled github-daily-activity.service &>/dev/null; then
        echo -e "  Enabled: ${GREEN}Yes${NC}"
    else
        echo -e "  Enabled: ${RED}No${NC}"
    fi
    echo ""

    # Repository status
    echo -e "${BOLD}Repository Status:${NC}"
    if validate_repository 2>/dev/null; then
        echo -e "  Valid: ${GREEN}Yes${NC}"
        echo -e "  Branch: $(detect_branch 2>/dev/null || echo 'Unknown')"
        echo -e "  Path: ${REPO_PATH}"

        # Check for pending changes
        cd "${REPO_PATH}" 2>/dev/null || true
        local changes
        changes=$(git status --porcelain 2>/dev/null | wc -l)
        if [[ ${changes} -gt 0 ]]; then
            echo -e "  Pending Changes: ${YELLOW}${changes} files${NC}"
        else
            echo -e "  Pending Changes: ${GREEN}None${NC}"
        fi
    else
        echo -e "  Valid: ${RED}No${NC}"
    fi
    echo ""

    # SSH status
    echo -e "${BOLD}SSH Status:${NC}"
    if check_ssh_auth 2>/dev/null; then
        echo -e "  Authentication: ${GREEN}Success${NC}"
    else
        echo -e "  Authentication: ${RED}Failed${NC}"
    fi
    echo ""

    # Internet status
    echo -e "${BOLD}Internet Status:${NC}"
    if ping -c "${PING_ATTEMPTS}" -W "${PING_TIMEOUT}" "${PING_HOST}" &>/dev/null; then
        echo -e "  Connection: ${GREEN}Available${NC}"
    else
        echo -e "  Connection: ${RED}Unavailable${NC}"
    fi
    echo ""

    # Log files
    echo -e "${BOLD}Log Files:${NC}"
    echo "  Activity: ${ACTIVITY_LOG}"
    echo "  Error: ${ERROR_LOG}"
    echo "  System: ${SYSTEM_LOG}"
    echo ""

    # History count
    if [[ -f "${SCRIPT_DIR}/${HISTORY_FILE}" ]]; then
        local count
        count=$(grep -c "^========================================$" "${SCRIPT_DIR}/${HISTORY_FILE}" 2>/dev/null || echo "0")
        count=$((count / 2))
        echo -e "${BOLD}Boot History:${NC}"
        echo "  Total boots recorded: ${count}"
    fi
    echo ""
}

show_version() {
    echo ""
    echo -e "${BOLD}GitHub Daily Activity${NC}"
    echo "Version: ${SCRIPT_VERSION}"
    echo "Date: ${SCRIPT_DATE}"
    echo "Author: SamanQasempour"
    echo "License: MIT"
    echo ""
}

# --------------------------------------------------------------------------
# Dry Run Function
# --------------------------------------------------------------------------
dry_run() {
    echo ""
    echo -e "${BOLD}========================================${NC}"
    echo -e "${BOLD}  Dry Run Mode${NC}"
    echo -e "${BOLD}========================================${NC}"
    echo ""

    log_message "INFO" "Running in dry-run mode..."

    # Show what would be collected
    echo -e "${BOLD}System Information:${NC}"
    echo "  Boot Time: $(get_boot_time)"
    echo "  Hostname: $(get_hostname)"
    echo "  Username: $(get_username)"
    echo "  OS: $(get_os)"
    echo "  Kernel: $(get_kernel)"
    echo "  Architecture: $(get_architecture)"
    echo "  CPU: $(get_cpu)"
    echo "  RAM: $(get_ram)"
    echo "  IP Address: $(get_ip_address)"
    echo "  Timezone: $(get_timezone)"
    echo "  Uptime: $(get_uptime)"
    echo ""

    # Show what would be written
    echo -e "${BOLD}Would append to:${NC} ${SCRIPT_DIR}/${HISTORY_FILE}"
    echo ""

    # Show boot entry
    echo -e "${BOLD}Boot Entry Preview:${NC}"
    generate_boot_entry
    echo ""

    # Check git status
    echo -e "${BOLD}Git Status:${NC}"
    if validate_repository 2>/dev/null; then
        echo "  Repository: Valid"
        echo "  Branch: $(detect_branch 2>/dev/null || echo 'Unknown')"

        cd "${REPO_PATH}" 2>/dev/null || true
        local changes
        changes=$(git status --porcelain 2>/dev/null | wc -l)
        echo "  Pending Changes: ${changes} files"
    else
        echo "  Repository: Invalid"
    fi
    echo ""

    # Check SSH
    echo -e "${BOLD}SSH Status:${NC}"
    if check_ssh_auth 2>/dev/null; then
        echo "  Authentication: Would succeed"
    else
        echo "  Authentication: Would fail"
    fi
    echo ""
}

# --------------------------------------------------------------------------
# Main Functions
# --------------------------------------------------------------------------
run_boot_activity() {
    log_message "INFO" "Starting boot activity recording..."
    log_system "Boot activity started"

    # Check dependencies
    if ! check_dependencies; then
        log_error "Missing dependencies"
        return 1
    fi

    # Check SSH authentication
    if ! check_ssh_auth; then
        log_error "SSH authentication failed. Please configure SSH keys."
        log_error "See: https://docs.github.com/en/authentication/connecting-to-github-with-ssh"
        log_system "SSH authentication failed"
        return 1
    fi

    # Wait for internet
    if ! wait_for_internet; then
        log_error "Failed to establish internet connection"
        return 1
    fi

    # Validate repository
    if ! validate_repository; then
        log_error "Repository validation failed"
        return 1
    fi

    # Pull latest changes
    if ! git_pull_safely; then
        log_error "Git pull failed"
        # Continue anyway - we can still commit locally
    fi

    # Append boot entry
    if ! append_boot_entry; then
        log_error "Failed to append boot entry"
        return 1
    fi

    # Commit and push
    if ! git_commit_and_push; then
        log_error "Git commit/push failed"
        log_error "Boot entry saved locally. Will retry on next boot."
        log_system "Git push failed - entry saved locally"
        return 1
    fi

    log_message "INFO" "Boot activity recording completed successfully"
    log_system "Boot activity completed successfully"
    return 0
}

# --------------------------------------------------------------------------
# Argument Parsing
# --------------------------------------------------------------------------
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --status)
                show_status
                exit 0
                ;;
            --debug)
                LOG_LEVEL="DEBUG"
                VERBOSE=true
                echo -e "${CYAN}Debug mode enabled${NC}"
                shift
                ;;
            --version|-v)
                show_version
                exit 0
                ;;
            --dry-run|-n)
                load_config
                dry_run
                exit 0
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                show_help
                exit 1
                ;;
        esac
    done
}

show_help() {
    echo ""
    echo -e "${BOLD}GitHub Daily Activity - Boot Logger${NC}"
    echo ""
    echo "Usage: ${SCRIPT_NAME} [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --status       Show current status"
    echo "  --debug        Enable debug mode"
    echo "  --version, -v  Show version"
    echo "  --dry-run, -n  Run in dry-run mode (no changes)"
    echo "  --help, -h     Show this help"
    echo ""
    echo "Examples:"
    echo "  ${SCRIPT_NAME}              # Run boot activity"
    echo "  ${SCRIPT_NAME} --status     # Show status"
    echo "  ${SCRIPT_NAME} --dry-run    # Preview without changes"
    echo "  ${SCRIPT_NAME} --debug      # Run with debug output"
    echo ""
}

# --------------------------------------------------------------------------
# Main Entry Point
# --------------------------------------------------------------------------
main() {
    parse_arguments "$@"
    load_config
    run_boot_activity
}

# Run main function
main "$@"
