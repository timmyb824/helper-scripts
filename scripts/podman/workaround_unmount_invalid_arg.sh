#!/bin/bash
#set -x

# Define the list of containers you want to remove
containers=("nextcloud_redis_1" "nextcloud_db_1" "nextcloud_nc_1")

for container in "${containers[@]}"; do
    echo "Now handling $container..."
    # First attempt to forcefully remove the container
    podman rm --force "$container"

    # Check if the removal failed
    if [ $? -ne 0 ]; then
        # Extract the mount path from the error message
        error_message=$(podman rm --force "$container" 2>&1)
        mount_path=$(echo "$error_message" | grep -oE '/var/home/[^ ]+merged' | head -n 1)
        echo "found mount_path=$mount_path"

        # If a mount path was found, attempt to unmount it using tmpfs
        if [ -n "$mount_path" ]; then
            podman unshare mount -t tmpfs none "$mount_path"

            podman rm --force "$container"
            # Check if the unmounting failed due to a non-empty directory
            if [ $? -ne 0 ]; then
                echo "Backup/move $mount_path directory"
                # Rename the directory if it's not empty
                mv "$mount_path" "${mount_path}_backup"

                # Finally, try to forcefully remove the container again
                podman rm --force "$container"
            fi
        fi
    fi
done
