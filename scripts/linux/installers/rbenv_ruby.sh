#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to install rbenv using the official installer script on Linux
install_rbenv_linux() {
  echo_with_color "$GREEN" "Installing rbenv and dependencies on Linux..."
  sudo apt update || exit_with_error "Failed to update apt."
  sudo apt install -y git curl autoconf bison build-essential libssl-dev libyaml-dev \
    libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev ||
    exit_with_error "Failed to install dependencies for rbenv and Ruby build."
  curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
}

# Function to initialize rbenv within the script
initialize_rbenv() {
  echo_with_color "$GREEN" "Initializing rbenv for the current Linux session..."
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
}

# Function to install Ruby and set it as the global version
install_and_set_ruby() {
  if [ -z "${RUBY_VERSION:-}" ]; then
    exit_with_error "RUBY_VERSION is not set. Please specify the Ruby version to install."
  fi

  if rbenv versions | grep -q "$RUBY_VERSION"; then
    echo_with_color "$GREEN" "Ruby version $RUBY_VERSION is already installed."
  else
    echo_with_color "$GREEN" "Installing Ruby version $RUBY_VERSION..."
    rbenv install "$RUBY_VERSION" || exit_with_error "Failed to install Ruby version $RUBY_VERSION."
  fi

  echo_with_color "$GREEN" "Setting Ruby version $RUBY_VERSION as global..."
  rbenv global "$RUBY_VERSION" || exit_with_error "Failed to set Ruby version $RUBY_VERSION as global."
  echo "Ruby installation completed. Ruby version set to $RUBY_VERSION."
}

# Main execution
if command_exists rbenv; then
  echo_with_color "$GREEN" "rbenv is already installed."
else
  if command_exists sudo && command_exists curl; then
    install_rbenv_linux || exit_with_error "Failed to install rbenv."
  else
    exit_with_error "sudo and curl are required to install rbenv."
  fi
fi

initialize_rbenv
install_and_set_ruby