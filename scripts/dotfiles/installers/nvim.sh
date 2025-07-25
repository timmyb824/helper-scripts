#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"


install_nvim_linux() {
    NVIM_RELEASE="nvim-linux-x86_64.tar.gz"
    NVIM_BIN_LOCATION="/opt/nvim-linux64"
    if curl -LO https://github.com/neovim/neovim/releases/download/stable/${NVIM_RELEASE}; then
        sudo rm -rf $NVIM_BIN_LOCATION
        sudo tar -C /opt -xzf $NVIM_RELEASE
        sudo rm -rf $NVIM_RELEASE
        sudo mv /opt/nvim-linux-x86_64 $NVIM_BIN_LOCATION
        echo_with_color "$GREEN_COLOR" "Neovim installed successfully on Linux."
    else
        echo_with_color "$RED_COLOR" "Error: The Neovim download failed."
        return 1
    fi
}

uninstall_existing_nvim() {
if [ -f /usr/bin/nvim ]; then
    echo_with_color "$YELLOW_COLOR" "Removing the existing Neovim installation..."
    if sudo apt remove -y neovim; then
        echo_with_color "$GREEN_COLOR" "Neovim removed successfully."
    else
        exit_with_error "Error: Failed to remove the existing Neovim installation."
    fi
else
    echo_with_color "$YELLOW_COLOR" "No existing Neovim installation found."
fi
}

if ! command_exists curl; then
    echo_with_color "$BLUE_COLOR" "Installing the 'curl' command..."
    sudo apt update && sudo apt install -y curl
fi

uninstall_existing_nvim
install_nvim_linux
