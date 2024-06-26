#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../../../init/init.sh"

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  error_exit "This script must be run as root."
fi

# Define the username
USERNAME="tbryant"

# Add the user
if id "$USERNAME" &>/dev/null; then
  echo "User $USERNAME already exists. Skipping user creation."
else
  sudo adduser "$USERNAME" || error_exit "Failed to add user $USERNAME."
fi

# Set the user's password
echo "Please set a password for the user $USERNAME:"
sudo passwd "$USERNAME" || error_exit "Failed to set password for user $USERNAME."

# Create a sudoers file for the user
SUDOERS_FILE="/etc/sudoers.d/$USERNAME"
echo "$USERNAME             ALL=(ALL)       ALL" | sudo tee "$SUDOERS_FILE" > /dev/null || error_exit "Failed to create sudoers file for user $USERNAME."

# Set the correct permissions for the sudoers file
sudo chmod 440 "$SUDOERS_FILE" || error_exit "Failed to set permissions on $SUDOERS_FILE."

echo "User $USERNAME has been created and granted sudo permissions successfully."
