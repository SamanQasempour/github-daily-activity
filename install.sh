#!/bin/bash
# ============================================================================
# GitHub Daily Activity - Installer
# ============================================================================
# Description: Automated installation script for github-daily-activity
# Author: SamanQasempour
# License: MIT
# Version: 1.0.0
# ============================================================================

set -Eeuo pipefail

# --------------------------------------------------------------------------
# Color Codes
# --------------------------------------------------------------------------
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# --------------------------------------------------------------------------
# Global Variables
# --------------------------------------------------------------------------
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SERVICE_NAME="github-daily-activity"
readonly SERVICE_FILE="${SERVICE_NAME}.service"
readonly SYSTEMD_DIR="/etc/systemd/system"
readonly INSTALL_DIR="/opt/${SERVICE_NAME}"

# --------------------------------------------------------------------------
# Utility Functions
# --------------------------------------------------------------------------
print_header() {
    echo ""
    echo -e "${BOLD}========================================${NC}"
    echo -e "${BOLD}  GitHub Daily Activity Installer${NC}"
    echo -e "${BOLD}========================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

print_step() {
    echo -e "${CYAN}[→]${NC} $1"
}

# --------------------------------------------------------------------------
# Pre-installation Checks
# --------------------------------------------------------------------------
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        echo ""
        echo "Please run:"
        echo "  sudo ${SCRIPT_DIR}/${SCRIPT_NAME}"
        echo ""
        exit 1
    fi
}

check_os() {
    print_step "Checking operating system..."

    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        local os_name="${ID}"
        local os_version="${VERSION_ID}"

        case "${os_name}" in
            ubuntu|debian|linuxmint|pop)
                print_success "Supported OS: ${PRETTY_NAME}"
                ;;
            *)
                print_warning "Untested OS: ${PRETTY_NAME}"
                print_warning "Installation may work, but is not guaranteed"
                ;;
        esac
    else
        print_warning "Cannot detect OS. Continuing anyway..."
    fi
}

check_dependencies() {
    print_step "Checking dependencies..."

    local missing_deps=()
    local required_commands=("git" "ssh" "ping" "who" "hostnamectl" "systemctl")

    for cmd in "${required_commands[@]}"; do
        if ! command -v "${cmd}" &>/dev/null; then
            missing_deps+=("${cmd}")
        fi
    done

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        print_step "Installing dependencies..."

        # Try to install missing packages
        local packages=()
        for dep in "${missing_deps[@]}"; do
            case "${dep}" in
                git) packages+=("git") ;;
                ssh) packages+=("openssh-client") ;;
                ping) packages+=("iputils-ping") ;;
                who) packages+=("util-linux") ;;
                hostnamectl) packages+=("systemd") ;;
                systemctl) packages+=("systemd") ;;
            esac
        done

        if [[ ${#packages[@]} -gt 0 ]]; then
            apt-get update -qq
            apt-get install -y "${packages[@]}"
            print_success "Dependencies installed"
        fi
    else
        print_success "All dependencies found"
    fi
}

check_git() {
    print_step "Checking Git installation..."

    if ! command -v git &>/dev/null; then
        print_error "Git is not installed"
        exit 1
    fi

    local git_version
    git_version=$(git --version | awk '{print $3}')
    print_success "Git version: ${git_version}"
}

check_ssh() {
    print_step "Checking SSH authentication..."

    local ssh_output
    if ssh_output=$(ssh -T git@github.com 2>&1); then
        print_success "SSH authentication successful"
    else
        # Check if it's the "Hi user!" message (exit code 1)
        if [[ "${ssh_output}" == *"You've successfully authenticated"* ]]; then
            print_success "SSH authentication successful"
        else
            print_error "SSH authentication failed"
            echo ""
            echo "Please set up SSH keys first:"
            echo "  1. Generate key: ssh-keygen -t ed25519 -C \"your_email@example.com\""
            echo "  2. Add to ssh-agent: eval \"\$(ssh-agent -s)\" && ssh-add ~/.ssh/id_ed25519"
            echo "  3. Add public key to GitHub: cat ~/.ssh/id_ed25519.pub"
            echo ""
            echo "See: https://docs.github.com/en/authentication/connecting-to-github-with-ssh"
            echo ""
            exit 1
        fi
    fi
}

# --------------------------------------------------------------------------
# Installation Functions
# --------------------------------------------------------------------------
create_install_dir() {
    print_step "Creating installation directory..."

    if [[ ! -d "${INSTALL_DIR}" ]]; then
        mkdir -p "${INSTALL_DIR}"
        print_success "Created: ${INSTALL_DIR}"
    else
        print_info "Directory already exists: ${INSTALL_DIR}"
    fi
}

copy_files() {
    print_step "Copying files..."

    local files=(
        "boot-log.sh"
        "config.conf"
    )

    for file in "${files[@]}"; do
        if [[ -f "${SCRIPT_DIR}/${file}" ]]; then
            cp "${SCRIPT_DIR}/${file}" "${INSTALL_DIR}/"
            chmod +x "${INSTALL_DIR}/${file}"
            print_success "Copied: ${file}"
        else
            print_error "File not found: ${file}"
            exit 1
        fi
    done

    # Create log files
    for log in activity.log error.log system.log history.log; do
        touch "${INSTALL_DIR}/${log}"
    done
    print_success "Created log files"
}

update_service_path() {
    print_step "Updating service file path..."

    local service_template="${SCRIPT_DIR}/systemd/${SERVICE_FILE}"

    if [[ ! -f "${service_template}" ]]; then
        print_error "Service file not found: ${service_template}"
        exit 1
    fi

    # Create service file with correct path
    cat > "${SYSTEMD_DIR}/${SERVICE_FILE}" << EOF
[Unit]
Description=GitHub Daily Activity - Boot Logger
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=${INSTALL_DIR}/boot-log.sh
RemainAfterExit=yes
StandardOutput=journal
StandardError=journal
WorkingDirectory=${INSTALL_DIR}

[Install]
WantedBy=multi-user.target
EOF

    print_success "Service file installed"
}

enable_service() {
    print_step "Enabling systemd service..."

    systemctl daemon-reload
    systemctl enable "${SERVICE_NAME}.service"
    print_success "Service enabled"
}

start_service() {
    print_step "Starting systemd service..."

    systemctl start "${SERVICE_NAME}.service"
    print_success "Service started"
}

verify_installation() {
    print_step "Verifying installation..."

    local errors=0

    # Check service status
    if systemctl is-active "${SERVICE_NAME}.service" &>/dev/null; then
        print_success "Service is active"
    else
        print_warning "Service is not active (this is normal - it runs on boot)"
    fi

    # Check if enabled
    if systemctl is-enabled "${SERVICE_NAME}.service" &>/dev/null; then
        print_success "Service is enabled"
    else
        print_error "Service is not enabled"
        ((errors++))
    fi

    # Check files exist
    local required_files=("boot-log.sh" "config.conf")
    for file in "${required_files[@]}"; do
        if [[ -f "${INSTALL_DIR}/${file}" ]]; then
            print_success "File exists: ${file}"
        else
            print_error "File missing: ${file}"
            ((errors++))
        fi
    done

    if [[ ${errors} -gt 0 ]]; then
        print_error "Installation verification failed"
        return 1
    fi

    print_success "Installation verified successfully"
    return 0
}

print_post_install() {
    echo ""
    echo -e "${BOLD}========================================${NC}"
    echo -e "${GREEN}${BOLD}  Installation Complete!${NC}"
    echo -e "${BOLD}========================================${NC}"
    echo ""
    echo -e "${BOLD}Next steps:${NC}"
    echo ""
    echo "  1. Ensure SSH keys are configured:"
    echo "     ssh -T git@github.com"
    echo ""
    echo "  2. The service will run automatically on next boot"
    echo ""
    echo -e "${BOLD}Useful commands:${NC}"
    echo ""
    echo "  Check status:    sudo systemctl status ${SERVICE_NAME}"
    echo "  Restart service: sudo systemctl restart ${SERVICE_NAME}"
    echo "  Stop service:    sudo systemctl stop ${SERVICE_NAME}"
    echo "  View logs:       journalctl -u ${SERVICE_NAME}"
    echo ""
    echo -e "${BOLD}View boot history:${NC}"
    echo ""
    echo "  cat ${INSTALL_DIR}/history.log"
    echo ""
    echo -e "${BOLD}Test without rebooting:${NC}"
    echo ""
    echo "  sudo ${INSTALL_DIR}/boot-log.sh --dry-run"
    echo ""
}

# --------------------------------------------------------------------------
# Main Installation
# --------------------------------------------------------------------------
install() {
    print_header

    # Pre-installation checks
    check_root
    check_os
    check_dependencies
    check_git
    check_ssh

    echo ""

    # Installation steps
    create_install_dir
    copy_files
    update_service_path
    enable_service
    start_service

    echo ""

    # Verify
    verify_installation

    # Post-installation info
    print_post_install
}

# --------------------------------------------------------------------------
# Main Entry Point
# --------------------------------------------------------------------------
main() {
    install
}

main "$@"
