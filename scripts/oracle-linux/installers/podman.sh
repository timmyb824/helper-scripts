#!/usr/bin/env bash

# Source necessary utilities
source "$(dirname "$BASH_SOURCE")/../../../init/init.sh"

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

# TODO: Install podman-compose

# Function to install Podman
install_podman()
    if ! sudo yum install -y podman; then
        exit_with_error "Failed to install Podman."
    fi

    echo_with_color "32" "Podman installed successfully."

    echo_with_color "33" "Configuring Podman..."
    
    local config_dir="$HOME/.config/containers"
    mkdir -p "$config_dir"

    if ! cp /etc/containers/registries.conf "$config_dir/"; then
        echo_with_color "31" "Failed to copy registries.conf file to $config_dir."
        return 1
    fi

    if ! echo "unqualified-search-registries = [\"docker.io\",\"quay.io\",\"container-registry.oracle.com\",\"ghcr.io\"]" >>"$config_dir/registries.conf"; then
        echo_with_color "$RED_COLOR" "Failed to add image registries to registry configuration."
        return 1
    fi

    # Enable containers to run after logout
    if ! sudo loginctl enable-linger "$USER"; then
        echo_with_color "31" "Failed to enable lingering for user $USER."
        return 1
    fi

    # Allow containers use of HTTP/HTTPS ports
    local sysctl_conf="/etc/sysctl.d/podman-privileged-ports.conf"
    echo "# Lowering privileged ports to allow us to run rootless Podman containers on lower ports" | sudo tee "$sysctl_conf"
    echo "# From: www.smarthomebeginner.com" | sudo tee -a "$sysctl_conf"
    echo "net.ipv4.ip_unprivileged_port_start=80" | sudo tee -a "$sysctl_conf"

    if ! sudo sysctl --load "$sysctl_conf"; then
        echo_with_color "31" "Failed to apply sysctl configuration for privileged ports."
        return 1
    fi

    echo_with_color "32" "Podman configuration completed successfully."
}


install_cni_plugin() {
    if [[ "$(lsb_release -cs)" == "jammy" ]]; then
        local cni_plugin_url="http://archive.ubuntu.com/ubuntu/pool/universe/g/golang-github-containernetworking-plugins/containernetworking-plugins_1.1.1+ds1-3ubuntu0.23.10.2_amd64.deb"
        local cni_plugin_deb="/tmp/containernetworking-plugins_1.1.1+ds1-3ubuntu0.23.10.2_amd64.deb"

        if ! wget -O "$cni_plugin_deb" "$cni_plugin_url"; then
            echo_with_color "31" "Failed to download CNI plugin package."
            return 1
        fi

        if ! sudo dpkg -i "$cni_plugin_deb"; then
            echo_with_color "31" "Failed to install CNI plugin package."
            return 1
        fi

        echo_with_color "32" "CNI plugin package installed successfully."
    else
        echo_with_color "33" "Skipping CNI plugin installation as it is not supported on $(lsb_release -cs)."
    fi
}

create_config_systemd_user_dir() {
    local config_dir="$HOME/.config/systemd/user"
    mkdir -p "$config_dir"
    echo_with_color "32" "Created systemd user directory at $config_dir."
}

symlink_podman_to_docker() {
    echo_with_color "33" "Symlinking Podman to Docker..."
    read -p "Do you want to symlink Podman to Docker? [y/N]: " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Creating the symlink..."
        if [ ! -S /run/podman/podman.sock ]; then
            echo_with_color "31" "Podman socket does not exist. Please ensure Podman is installed and running."
            return 1
        fi
        if [ -e /var/run/docker.sock ] || [ -L /var/run/docker.sock ]; then
            echo_with_color "33" "Docker socket already exists. Please remove or rename it before symlinking."
            return 1
        fi
        if sudo ln -s /run/podman/podman.sock /var/run/docker.sock; then
            echo_with_color "32" "Podman symlinked to Docker successfully."
            return 0
        else
            echo_with_color "31" "Failed to symlink Podman to Docker."
            return 1
        fi
    else
        echo_with_color "32" "Skipping symlink creation."
        return 0
    fi
}

# Main script execution
if check_podman_installed; then
    echo_with_color "$YELLOW_COLOR" "Skipping installation as Podman is already installed."
else
    echo_with_color "33" "Podman is not installed. Installing Podman..."
    install_podman
    install_cni_plugin
    create_config_systemd_user_dir
fi
