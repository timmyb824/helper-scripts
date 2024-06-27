#!/usr/bin/env bash

# Exit on any error
set -e

# Source common functions with a check
INIT_SCRIPT_PATH="$(dirname "$BASH_SOURCE")/init/init.sh"
if [[ -f "$INIT_SCRIPT_PATH" ]]; then
    source "$INIT_SCRIPT_PATH"
else
    exit_with_error "Unable to source init.sh, file not found."
fi

# Function to make a script executable and run it
change_and_run_script() {
    local script="$1"
    if ask_yes_or_no "Do you want to run $script?"; then
        echo_with_color "$GREEN_COLOR" "Running $script..."
        chmod +x "$script"  # Make the script executable
        "$script"           # Execute the script
        echo_with_color "$GREEN_COLOR" "$script completed."
    else
        echo_with_color "$YELLOW_COLOR" "Skipping $script..."
    fi
}

# Main installation process
echo_with_color "$GREEN_COLOR" "Starting package installations for linux..."

SCRIPT_DIR="dot_config/bin"

# An array of scripts to run, for cleaner management and scalability
declare -a scripts_to_run=(
    "package-managers/apt.sh"
    "package-managers/pkgx.sh"
    "package-managers/basher.sh"
    "package-managers/krew.sh"
    "package-managers/micro.sh"
    "installers/pyenv_python.sh"
    "package-managers/pip.sh"
    "package-managers/pipx.sh"
    "installers/tfenv_terraform.sh"
    "installers/tailscale.sh"
    "installers/headscale.sh"
    "installers/rbenv_ruby.sh"
    "package-managers/gem.sh"
    "installers/rust.sh"
    "package-managers/cargo.sh"
    "installers/fnm_node.sh"
    "package-managers/npm.sh"
    "installers/atuin.sh"
    "installers/ngrok.sh"
    "installers/docker.sh"
    "installers/podman.sh"
    "installers/promtail.sh"
    "configuration/go_directories.sh"
    "package-managers/go.sh"
    "configuration/mount_nas.sh"
    "installers/nvim.sh"
    "installers/fzf.sh"
    "package-managers/gh_cli.sh"
    "package-managers/ghq.sh"
    "package-managers/gitopolis.sh"
    "installers/fonts.sh"
    "installers/jetbrainsmono_font.sh"
    "installers/glances.sh"
    "installers/node_exporter.sh"
    "installers/zsh_shell.sh"
    "installers/misc.sh"
)

# Iterate through the scripts and run them
for script in "${scripts_to_run[@]}"; do
    change_and_run_script "$SCRIPT_DIR/$script"
done

echo_with_color "$GREEN_COLOR" "All linux packages have been installed."
