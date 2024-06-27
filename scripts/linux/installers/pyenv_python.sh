#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to install pyenv and Python dependencies for Linux
install_pyenv_linux() {
    echo_with_color "$GREEN" "Installing pyenv and Python dependencies for Linux..."
    sudo apt update
    sudo apt install -y build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev curl \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

    if command_exists curl; then
        curl https://pyenv.run | bash
    else
        exit_with_error "The curl command is required to install pyenv but it's not installed."
    fi
}

# Function to install and set up Python version using pyenv
setup_python_version() {
    if pyenv install -s "${PYTHON_VERSION}"; then
        echo_with_color "$GREEN_COLOR" "Python ${PYTHON_VERSION} installed successfully."
    else
        exit_with_error "Failed to install Python ${PYTHON_VERSION}, please check pyenv setup."
    fi

    if pyenv global "${PYTHON_VERSION}"; then
        echo_with_color "$GREEN_COLOR" "Python ${PYTHON_VERSION} is now in use."
    else
        exit_with_error "Failed to set Python ${PYTHON_VERSION} as global, please check pyenv setup."
    fi
}


initialize_pyenv() {
    # Initialize pyenv for the current session
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
}

# Main installation process
if [ -z "${PYTHON_VERSION:-}" ]; then
    exit_with_error "PYTHON_VERSION is not set. Please specify the Python version to install."
fi

if [ ! -f "$HOME/.pyenv/bin/pyenv" ]; then
    echo_with_color "$YELLOW" "pyenv could not be found or the installation is incomplete."

    if ! command_exists sudo; then
        exit_with_error "sudo command is required but not found. Please install sudo first."
    fi

    install_pyenv_linux
    initialize_pyenv
    setup_python_version
else
    echo_with_color "$GREEN" "pyenv is already installed and appears to be properly set up."
    initialize_pyenv
    setup_python_version
fi