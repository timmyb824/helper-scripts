#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <network_name>"
  exit 1
fi

NETWORK_NAME="$1"
SYSTEMD_USER_DIR="$HOME/.config/containers/systemd"

# Function to create systemd unit file for a container
generate_systemd_unit() {
  local network_name="$1"

  # Create systemd user directory if it doesn't exist
  mkdir -p "${SYSTEMD_USER_DIR}"
  cd "${SYSTEMD_USER_DIR}" || exit

  # Generate systemd unit files from running containers
  if podlet --file . generate network "${network_name}"; then
    echo "Successfully generated systemd unit file for network: ${network_name}"
  else
    echo "Failed to generate systemd unit file for network: ${network_name}"
    exit 1
  fi
}

daemon_reload() {
  systemctl --user daemon-reload
}

# Main script execution
generate_systemd_unit "${NETWORK_NAME}"
daemon_reload

