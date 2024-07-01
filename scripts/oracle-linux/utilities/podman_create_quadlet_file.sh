#!/bin/bash

# Check if container name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <container_name>"
  exit 1
fi

CONTAINER_NAME="$1"
SYSTEMD_USER_DIR="$HOME/.config/containers/systemd"

# Function to create systemd unit file for a container
generate_systemd_unit() {
  local container_name="$1"

  # Create systemd user directory if it doesn't exist
  mkdir -p "${SYSTEMD_USER_DIR}"
  cd "${SYSTEMD_USER_DIR}" || exit

  # Generate systemd unit files from running containers
  if podlet --file . generate container "${container_name}"; then
    echo "Successfully generated systemd unit file for container: ${container_name}"
  else
    echo "Failed to generate systemd unit file for container: ${container_name}"
    exit 1
  fi
}

enable_systemd_service() {
  local container_name="$1"
  systemctl --user daemon-reload
  if systemctl --user enable --now "${container_name}.service"; then
    echo "Successfully enabled systemd service for container: ${container_name}"
  else
    echo "Failed to enable systemd service for container: ${container_name}"
    exit 1
  fi
}

check_service_status() {
  local container_name="$1"
  if systemctl --user status "${container_name}.service"; then
    echo "Successfully checked status of systemd service for container: ${container_name}"
  else
    echo "Failed to check status of systemd service for container: ${container_name}"
    exit 1
  fi
}

# Main script execution
generate_systemd_unit "${CONTAINER_NAME}"
enable_systemd_service "${CONTAINER_NAME}"
check_service_status "${CONTAINER_NAME}"
