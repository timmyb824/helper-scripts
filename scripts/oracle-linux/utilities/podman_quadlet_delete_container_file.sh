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

if systemctl --user stop "$UNIT_FILE"; then
    echo "Service $SERVICE_NAME has been stopped."
else
    echo "Service $SERVICE_NAME is not running."
fi

# Disable the user service
# if systemctl --user disable "$UNIT_FILE"; then
#     echo "Service $SERVICE_NAME has been disabled."
# else
#     echo "Service $SERVICE_NAME is not enabled."
# fi

echo "Removing service and container files for $SERVICE_NAME."
rm -f "$CONTAINER_FILE" || echo "Container file $CONTAINER_FILE does not exist."

systemctl --user daemon-reload

# if systemctl --user reset-failed "$UNIT_FILE" 2>/dev/null; then
#     echo "Failed state for $SERVICE_NAME has been reset."
# fi

# Stop and remove the container
podman stop "$SERVICE_NAME" || echo "Container $SERVICE_NAME is not running."
podman rm "$SERVICE_NAME" || echo "Container $SERVICE_NAME does not exist."

echo "Service and container for $SERVICE_NAME have been removed."

