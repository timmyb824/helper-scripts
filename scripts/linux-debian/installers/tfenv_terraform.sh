#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

terraform_version() {
    local version_output
    if version_output=$(terraform --version 2>&1); then
        echo "$version_output" | head -n 1
    else
        return 1
    fi
}

# Function to install tfenv on Linux
install_tfenv_linux() {
    if ! command_exists git; then
        exit_with_error "git not found. Please install git first."
    else
        # Clone tfenv into ~/.tfenv if it doesn't already exist
        if [[ ! -d "$HOME/.tfenv" ]]; then
            git clone --depth=1 https://github.com/tfutils/tfenv.git "$HOME/.tfenv"
        fi

        # Create symlink in a directory that is on the user's PATH
        TFENV_BIN="$HOME/.local/bin"
        mkdir -p "$TFENV_BIN"

        # Symlink all tfenv binaries
        for binary in "$HOME/.tfenv/bin/"*; do
            binary_name=$(basename "$binary")
            tfenv_symlink_target="$TFENV_BIN/$binary_name"
            if [ ! -L "$tfenv_symlink_target" ]; then
                ln -s "$binary" "$tfenv_symlink_target"
            fi
        done

        # Use the previously defined function to add directory to PATH if it's not already there
        add_to_path_exact_match "$TFENV_BIN"

        # Check if tfenv is accessible
        if ! command_exists tfenv; then
            exit_with_error "tfenv installation failed. Please ensure $TFENV_BIN is in your PATH."
        fi
    fi
}
# Function to install and set the desired version of Terraform
install_terraform_version() {
    echo_with_color "$GREEN_COLOR" "Installing Terraform version ${TF_VERSION}..."
    if tfenv install "${TF_VERSION}" && tfenv use "${TF_VERSION}"; then
        installed_version=$(terraform version | head -n 1)
        echo_with_color "$GREEN_COLOR" "Installed Terraform version $installed_version successfully."
    else
        exit_with_error "Failed to install or use Terraform version ${TF_VERSION}. Please check tfenv setup."
    fi
}

# Main script execution
if [[ -z "${TF_VERSION}" ]]; then
    exit_with_error "TF_VERSION is not set. Please export TF_VERSION with the desired Terraform version."
fi


# Check if Terraform is installed and working
if ! terraform_version >/dev/null; then
    echo_with_color "$YELLOW_COLOR" "Terraform could not be found or is not properly installed."
    install_tfenv_linux
    install_terraform_version
else
    current_version=$(terraform_version)
    echo_with_color "$GREEN_COLOR" "Terraform is already installed and working: $current_version"
    # Optionally check if the current version matches TF_VERSION and install if necessary
    if [[ "$current_version" != "Terraform v${TF_VERSION}"* ]]; then
        install_terraform_version
    else
        echo_with_color "$GREEN_COLOR" "Terraform version ${TF_VERSION} is already in use."
    fi
fi