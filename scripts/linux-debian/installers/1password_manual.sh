#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

command_installed_preferred() {
    local cmd_path
    cmd_path=$(command -v "$1" 2>/dev/null)
    [[ $cmd_path == $HOME/.local/bin/* ]]
}

install_op_cli_linux() {
    # Define the version and architecture
    OP_VERSION="v2.26.1"
    ARCH="$(dpkg --print-architecture)"

    # Define the URL for downloading the 1Password CLI
    OP_URL="https://cache.agilebits.com/dist/1P/op2/pkg/${OP_VERSION}/op_linux_${ARCH}_${OP_VERSION}.zip"

    # Check if op is already installed and at the desired version
    if command -v op >/dev/null 2>&1; then
        INSTALLED_VERSION=$(op --version)
        if [ "$INSTALLED_VERSION" == "$OP_VERSION" ]; then
            echo_with_color "$GREEN_COLOR" "1Password CLI is already at the latest version ($INSTALLED_VERSION)."
            return 0
        fi
    fi

    # Download and install the 1Password CLI
    if wget "$OP_URL" -O op.zip && \
       unzip -d op op.zip && \
       sudo mv op/op /usr/local/bin/ && \
       rm -r op.zip op; then
        # Set up the group and permissions
        sudo groupadd -f onepassword-cli
        sudo chgrp onepassword-cli /usr/local/bin/op
        sudo chmod g+s /usr/local/bin/op
        echo_with_color "$GREEN_COLOR" "1Password CLI installed successfully."
    else
        echo_with_color "$RED_COLOR" "Error: The 1Password CLI installation failed."
        return 1
    fi
}

install_wget_and_unzip() {
    local install_required=false

    if ! command_installed_preferred wget; then
        if ! command_exists wget; then
            install_required=true
        elif ! command_installed_preferred unzip; then
            if ! command_exists unzip; then
                install_required=true
            fi
        fi

        if [ "$install_required" = true ]; then
            echo_with_color "$BLUE_COLOR" "Installing the 'wget' and 'unzip' commands..."
            sudo apt update && sudo apt install -y wget unzip
        fi
    fi
}

uninstall_wget_and_unzip() {
    if ! command_installed_preferred wget; then
        if command_exists wget; then
            echo_with_color "$BLUE_COLOR" "Uninstalling the 'wget' command..."
            sudo apt remove -y wget
        fi
    fi
    if ! command_installed_preferred unzip; then
        if command_exists unzip; then
            echo_with_color "$BLUE_COLOR" "Uninstalling the 'unzip' command..."
            sudo apt remove -y unzip
        fi
    fi
}

install_wget_and_unzip
install_op_cli_linux
uninstall_wget_and_unzip
