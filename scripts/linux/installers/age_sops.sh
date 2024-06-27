#!/usr/bin/env bash

# Define safe_remove_command function and other necessary utilities
source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to install sops on Linux
install_sops_linux() {
    echo_with_color "$GREEN_COLOR" "Downloading sops binary for Linux..."
    SOPS_BINARY="sops-${SOPS_VERSION}.linux.amd64"
    SOPS_URL="https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/${SOPS_BINARY}"

    if curl -LO "$SOPS_URL"; then
        sudo mv "$SOPS_BINARY" /usr/local/bin/sops
        sudo chmod +x /usr/local/bin/sops
        echo_with_color "$GREEN_COLOR" "sops installed successfully on Linux."
    else
        echo_with_color "$RED_COLOR" "Error: Failed to download sops from the URL: $SOPS_URL"
        return 1
    fi
}

# Function to install age on Linux
install_age_linux() {
    echo_with_color "$GREEN_COLOR" "Downloading age binary for Linux..."
    AGE_BINARY="age-${AGE_VERSION}-linux-amd64.tar.gz"
    AGE_URL="https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/${AGE_BINARY}"

    if curl -LO "$AGE_URL"; then
        tar -xvf "$AGE_BINARY"
        sudo mv age/age /usr/local/bin/age
        rm -rf age "$AGE_BINARY"
        echo_with_color "$GREEN_COLOR" "age installed successfully on Linux."
    else
        echo_with_color "$RED_COLOR" "Error: Failed to download age from the URL: $AGE_URL"
        return 1
    fi
}

# Check and install sops if not installed
if command_exists sops; then
    echo_with_color "$YELLOW_COLOR" "sops is already installed on Linux."
else
    if ! install_sops_linux; then
        exit_with_error "sops installation failed." 1
    fi
fi

# Check and install age if not installed
if command_exists age; then
    echo_with_color "$YELLOW_COLOR" "age is already installed on Linux."
else
    if ! install_age_linux; then
        exit_with_error "age installation failed." 1
    fi
fi