#!/bin/bash
# ============================================================================
# GitHub Daily Activity - Uninstaller
# ============================================================================
# Description: Automated uninstallation script for github-daily-activity
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
    echo -e "${BOLD}  GitHub Daily Activity Uninstaller${NC}"
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
# Pre-uninstallation Checks
# --------------------------------------------------------------------------
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        echo ""
        echo "Please run:"
        echo "  sudo ${SCRIPT_DIR:-.}/${SCRIPT_NAME}"
        echo ""
        exit 1
    fi
}

confirm_uninstall() {
    echo -e "${YELLOW}Warning: This will remove github-daily-activity from your system.${NC}"
    echo ""
    echo "The following will be removed:"
    echo "  - systemd service"
    echo "  - installed files in ${INSTALL_DIR}"
    echo "  - log files"
    echo ""
    echo "The git repository will NOT be deleted."
    echo ""

    read -p "Are you sure you want to uninstall? (y/N): " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        print_info "Uninstallation cancelled"
        exit 0
    fi
    echo ""
}

# --------------------------------------------------------------------------
# Uninstallation Functions
# --------------------------------------------------------------------------
stop_service() {
    print_step "Stopping service..."

    if systemctl is-active "${SERVICE_NAME}.service" &>/dev/null; then
        systemctl stop "${SERVICE_NAME}.service"
        print_success "Service stopped"
    else
        print_info "Service is not running"
    fi
}

disable_service() {
    print_step "Disabling service..."

    if systemctl is-enabled "${SERVICE_NAME}.service" &>/dev/null; then
        systemctl disable "${SERVICE_NAME}.service"
        print_success "Service disabled"
    else
        print_info "Service is not enabled"
    fi
}

remove_service_file() {
    print_step "Removing service file..."

    if [[ -f "${SYSTEMD_DIR}/${SERVICE_FILE}" ]]; then
        rm -f "${SYSTEMD_DIR}/${SERVICE_FILE}"
        systemctl daemon-reload
        print_success "Service file removed"
    else
        print_info "Service file not found"
    fi
}

remove_installed_files() {
    print_step "Removing installed files..."

    if [[ -d "${INSTALL_DIR}" ]]; then
        rm -rf "${INSTALL_DIR}"
        print_success "Installation directory removed: ${INSTALL_DIR}"
    else
        print_info "Installation directory not found"
    fi
}

verify_removal() {
    print_step "Verifying removal..."

    local errors=0

    # Check service
    if systemctl cat "${SERVICE_NAME}.service" &>/dev/null; then
        print_error "Service file still exists"
        ((errors++))
    else
        print_success "Service file removed"
    fi

    # Check installation directory
    if [[ -d "${INSTALL_DIR}" ]]; then
        print_error "Installation directory still exists"
        ((errors++))
    else
        print_success "Installation directory removed"
    fi

    if [[ ${errors} -gt 0 ]]; then
        print_warning "Some files could not be removed"
        return 1
    fi

    print_success "Uninstallation verified successfully"
    return 0
}

print_post_uninstall() {
    echo ""
    echo -e "${BOLD}========================================${NC}"
    echo -e "${GREEN}${BOLD}  Uninstallation Complete!${NC}"
    echo -e "${BOLD}========================================${NC}"
    echo ""
    echo -e "${BOLD}Note:${NC}"
    echo ""
    echo "  The git repository has NOT been deleted."
    echo "  If you want to remove it, run:"
    echo ""
    echo "    rm -rf ${INSTALL_DIR}"
    echo ""
    echo -e "${BOLD}To reinstall:${NC}"
    echo ""
    echo "  git clone https://github.com/SamanQasempour/github-daily-activity.git"
    echo "  cd github-daily-activity"
    echo "  sudo ./install.sh"
    echo ""
}

# --------------------------------------------------------------------------
# Main Uninstallation
# --------------------------------------------------------------------------
uninstall() {
    print_header

    # Pre-uninstallation checks
    check_root
    confirm_uninstall

    # Uninstallation steps
    stop_service
    disable_service
    remove_service_file
    remove_installed_files

    echo ""

    # Verify
    verify_removal

    # Post-uninstallation info
    print_post_uninstall
}

# --------------------------------------------------------------------------
# Main Entry Point
# --------------------------------------------------------------------------
main() {
    uninstall
}

main "$@"
