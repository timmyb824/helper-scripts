#!/usr/bin/env bash

# Source necessary utilities
source "$(dirname "$BASH_SOURCE")/../../init/init.sh"

# Function to install sops on Linux
install_sops_oracle() {
    if command_exists sops; then
        msg_info "sops is already installed on Linux."
        return 0
    fi

    msg_info "Downloading sops binary for Linux..."
    SOPS_BINARY="sops-${SOPS_VERSION}-1.aarch64.rpm"
    SOPS_URL="https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/${SOPS_BINARY}"

    if curl -LO "$SOPS_URL"; then
        yum install -y "$SOPS_BINARY"
        rm "$SOPS_BINARY"
        msg_ok "sops installed successfully on Linux."
    else
        msg_error "Error: Failed to download sops from the URL: $SOPS_URL"
        return 1
    fi
}

# Function to install age on Linux
install_age_oracle() {
    if command_exists age; then
        msg_info "age is already installed on Linux."
        return 0
    fi

    # check for go and install if found
    if ! command_exists go; then
        msg_error "Go is not installed. Please install Go and try again."
        return 1
    fi

    # Ensure GOPATH is set and in PATH
    if [ -z "$GOPATH" ]; then
        export GOPATH=$HOME/go
        msg_warn "GOPATH was not set. Setting to $GOPATH"
    fi

    # Add GOPATH/bin to PATH if not already present
    if [[ ":$PATH:" != *":$GOPATH/bin:"* ]]; then
        export PATH="$PATH:$GOPATH/bin"
        msg_warn "Added $GOPATH/bin to PATH"
    fi

    msg_info "Installing age with go..."
    if go install filippo.io/age/cmd/...@latest; then
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

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
    handle_error "This script must be run as root"
fi

# Check if system is aarch64
if [[ $(uname -m) != "aarch64" ]]; then
    handle_error "This script is intended for aarch64 architecture only"
fi

install_sops_oracle
install_age_oracle
