#!/usr/bin/env bash

# Source necessary utilities
source "$(dirname "$BASH_SOURCE")/../../init/init.sh"

# Function to check if Podman is installed
check_podman_installed() {
    if command_exists podman; then
        echo_with_color "$YELLOW_COLOR" "Podman is already installed."
        podman --version
        return 0
    else
        return 1
    fi
}

initialize_pip_linux() {
    if command_exists pip; then
        echo_with_color "$GREEN_COLOR" "pip is already installed."
        return
    fi

    local pip_path="$HOME/.pyenv/shims/pip"
    if [[ -x "$pip_path" ]]; then
        echo_with_color "$GREEN_COLOR" "Adding pyenv pip to PATH."
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)"
    else
        echo_with_color "$YELLOW_COLOR" "pip is not installed. Please run pyenv_python.sh first."
        exit_with_error "pip installation required"
    fi
}

# Function to install Podman
install_podman() {
    if ! sudo yum install -y container-tools; then
        exit_with_error "Failed to install Podman."
    fi

    if podman --version; then
        echo_with_color "$GREEN_COLOR" "Podman has been installed successfully."
    else
        exit_with_error "Failed to install Podman."
    fi

    echo_with_color "$YELLOW_COLOR" "Configuring Podman..."

    local config_dir="$HOME/.config/containers"
    mkdir -p "$config_dir"

    if ! cp /etc/containers/registries.conf "$config_dir/"; then
        echo_with_color "$RED_COLOR" "Failed to copy registries.conf file to $config_dir."
        return 1
    fi

    if ! echo "unqualified-search-registries = [\"docker.io\",\"quay.io\",\"container-registry.oracle.com\",\"ghcr.io\"]" >>"$config_dir/registries.conf"; then
        echo_with_color "$RED_COLOR" "Failed to add image registries to registry configuration."
        return 1
    fi

    # Enable containers to run after logout
    if ! sudo loginctl enable-linger "$USER"; then
        echo_with_color "$RED_COLOR" "Failed to enable lingering for user $USER."
        return 1
    fi

    # Allow containers use of HTTP/HTTPS ports
    local sysctl_conf="/etc/sysctl.d/podman-privileged-ports.conf"
    echo "# Lowering privileged ports to allow us to run rootless Podman containers on lower ports" | sudo tee "$sysctl_conf"
    echo "# From: www.smarthomebeginner.com" | sudo tee -a "$sysctl_conf"
    echo "net.ipv4.ip_unprivileged_port_start=80" | sudo tee -a "$sysctl_conf"

    if ! sudo sysctl --load "$sysctl_conf"; then
        echo_with_color "$RED_COLOR" "Failed to apply sysctl configuration for privileged ports."
        return 1
    fi

    if ! pip install podman-compose; then
        echo_with_color "$RED_COLOR" "Failed to install podman-compose."
        return 1
    fi

    echo_with_color "$GREEN_COLOR" "Podman configuration completed successfully."
}

create_config_systemd_user_dir() {
    local config_dir="$HOME/.config/systemd/user"
    mkdir -p "$config_dir"
    echo_with_color "$GREEN_COLOR" "Created systemd user directory at $config_dir."
}

symlink_podman_to_docker() {
    echo_with_color "$YELLOW_COLOR" "Symlinking Podman to Docker..."
    read -p "Do you want to symlink Podman to Docker? [y/N]: " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Creating the symlink..."
        if [ ! -S /run/podman/podman.sock ]; then
            echo_with_color "$RED_COLOR" "Podman socket does not exist. Please ensure Podman is installed and running."
            return 1
        fi
        if [ -e /var/run/docker.sock ] || [ -L /var/run/docker.sock ]; then
            echo_with_color "$YELLOW_COLOR" "Docker socket already exists. Please remove or rename it before symlinking."
            return 1
        fi
        if sudo ln -s /run/podman/podman.sock /var/run/docker.sock; then
            echo_with_color "$GREEN_COLOR" "Podman symlinked to Docker successfully."
            return 0
        else
            echo_with_color "$RED_COLOR" "Failed to symlink Podman to Docker."
            return 1
        fi
    else
        echo_with_color "$GREEN_COLOR" "Skipping symlink creation."
        return 0
    fi
}

# Main script execution
if check_podman_installed; then
    echo_with_color "$YELLOW_COLOR" "Skipping installation as Podman is already installed."
else
    echo_with_color "$BLUE_COLOR" "Podman is not installed. Installing Podman..."
    initialize_pip_linux
    install_podman
    create_config_systemd_user_dir
fi
