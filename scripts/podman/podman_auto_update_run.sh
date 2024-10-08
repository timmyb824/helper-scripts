# THIS FILE IS RUN VIA CRON SO DON'T SOURCE FUNCTIONS FROM COMMON.SH
#!/bin/bash

log_file="$HOME/DEV/logs/podman-auto-update.log"

msg_info() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

msg_ok() {
    echo -e "\033[1;32m[OK]\033[0m $1"
}

msg_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

handle_error() {
    msg_error "$1"
    exit 1
}

logger() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$log_file"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to send a signal to Healthchecks.io
signal_healthchecks() {
    msg_info "Sending signal to Healthchecks.io"
    local status=$1
    local log_msg="cron for $HOSTNAME"
    curl -m 10 --retry 5 --data-raw "${log_msg}" "https://healthchecks.timmybtech.com/ping/${PODMAN_AUTO_UPDATE_IMAGES_CRON_UUID}/${status}" >/dev/null 2>&1
}

if [ ! -d "$(dirname "$log_file")" ]; then
    msg_info "Creating log directory: $(dirname "$log_file")"
    if mkdir -p "$(dirname "$log_file")"; then
        msg_ok "Log directory created successfully."
    else
        handle_error "Failed to create log directory."
    fi
fi

if ! command_exists podman; then
    handle_error "podman is not installed."
fi

# Check for updates
updates=$(podman auto-update --dry-run --format "{{.Image}} {{.Updated}}")

pending_updates=$(echo "$updates" | grep "pending")

if [[ -z "$pending_updates" ]]; then
    msg_info "No updates available."
    logger "No updates available."
    signal_healthchecks 0
else
    msg_info "Updates available for the following images:"
    logger "Updates available for the following images:"
    echo "$pending_updates" | tee -a "$log_file"

    # Perform the update
    if podman auto-update; then
        msg_ok "Podman auto-update completed successfully."
        logger "Podman auto-update completed successfully."
        signal_healthchecks 0
    else
        msg_error "Podman auto-update failed."
        logger "Podman auto-update failed."
        signal_healthchecks 1
    fi
fi
