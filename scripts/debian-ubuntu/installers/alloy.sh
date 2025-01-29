#!/usr/bin/env bash

source "../../init/init.sh"

msg_info "Starting Alloy installation..."

# Install required dependencies
msg_info "Installing dependencies..."
sudo apt install -y gpg

# Set up Grafana repository
msg_info "Setting up Grafana repository..."
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg >/dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

# Update package list and install Alloy
msg_info "Updating package list and installing Alloy..."
sudo apt-get update
sudo apt install -y alloy

# Check if Promtail is running
msg_info "Checking Promtail status..."
if systemctl is-active --quiet promtail; then
    msg_info "Promtail is running. Proceeding with configuration conversion..."

    # Backup existing Alloy config if it exists
    if [ -f "/etc/alloy/config.alloy" ]; then
        msg_info "Backing up existing Alloy config..."
        sudo mv /etc/alloy/config.alloy /etc/alloy/config.alloy.orig
    fi

    # Convert Promtail config to Alloy config
    msg_info "Converting Promtail config to Alloy format..."
    sudo alloy convert --source-format=promtail --output=/etc/alloy/config.alloy /etc/promtail/config.yaml

    # Stopping and disabling Promtail
    msg_info "Stopping and disabling Promtail..."
    sudo systemctl stop promtail
    sudo systemctl disable promtail

    # Start and enable Alloy service
    msg_info "Starting and enabling Alloy service..."
    sudo systemctl enable --now alloy

    # Check if Alloy started successfully
    if systemctl is-active --quiet alloy; then
        msg_info "Alloy started successfully."
        msg_ok "Migration from Promtail to Alloy completed successfully!"
    else
        msg_error "Failed to start Alloy service. Please check the logs with: journalctl -u alloy"
    fi
else
    msg_warning "Promtail is not running. Installing Alloy without migration..."
    sudo systemctl enable --now alloy
fi
