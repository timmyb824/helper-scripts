#!/bin/bash

# Check if a service name was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <service-name>"
    exit 1
fi

# Service name is the first argument
SERVICE_NAME="$1"
UNIT_FILE="$SERVICE_NAME.service"
CONTAINER_FILE="$HOME/.config/containers/systemd/$SERVICE_NAME.container"

# Stop the user service
systemctl --user stop "$UNIT_FILE"

# Disable the user service
systemctl --user disable "$UNIT_FILE"

rm -f "$CONTAINER_FILE"

systemctl --user daemon-reload
systemctl --user reset-failed "$UNIT_FILE"

# Stop and remove the container
podman stop "$SERVICE_NAME" || echo "Container $SERVICE_NAME is not running."
podman rm "$SERVICE_NAME" || echo "Container $SERVICE_NAME does not exist."

echo "Service and container for $SERVICE_NAME have been removed."

