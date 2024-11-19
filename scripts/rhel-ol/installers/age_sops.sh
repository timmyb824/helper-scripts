#!/usr/bin/env bash

# Source necessary utilities
source "$(dirname "$BASH_SOURCE")/../../init/init.sh"

GO_BIN="/usr/local/go/bin/go"

# Function to install sops on Linux
install_sops_oracle() {
    if command_exists sops; then
        msg_info "sops is already installed on Linux."
        return 0
    fi

    msg_info "Installing sops with go..."
    if $GO_BIN install github.com/getsops/sops/v3@latest; then
        # Verify the installation
        if command_exists sops; then
            msg_ok "sops installed successfully on Linux."
        else
            msg_error "sops binary not found in PATH after installation"
            return 1
        fi
    else
        msg_error "Error: Failed to install sops with go."
        return 1
    fi
}

# Function to install age on Linux
install_age_oracle() {
    if command_exists age; then
        msg_info "age is already installed on Linux."
        return 0
    fi

    msg_info "Installing age with go..."
    if $GO_BIN install filippo.io/age/cmd/...@latest; then
        # Verify the installation
        if command_exists age; then
            msg_ok "age installed successfully on Linux."
        else
            msg_error "age binary not found in PATH after installation"
            return 1
        fi
    else
        msg_error "Error: Failed to install age with go."
        return 1
    fi
}

# Check if system is aarch64
if [[ $(uname -m) != "aarch64" ]]; then
    handle_error "This script is intended for aarch64 architecture only"
fi

if ! command_exists "$GO_BIN"; then
    msg_error "Go is not installed. Please install Go and try again."
    return 1
fi

install_sops_oracle
install_age_oracle
