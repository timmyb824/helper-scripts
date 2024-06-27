#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

install_local_send() {
    local_send_version="1.14.0"
    local_send_deb="LocalSend-${local_send_version}-linux-x86-64.deb"
    local_send_url="https://github.com/localsend/localsend/releases/download/v${local_send_version}/${local_send_deb}"
    if ! command_exists "localsend"; then
        echo_with_color "$YELLOW_COLOR" "LocalSend is not installed."
        ask_yes_or_no "Do you want to install local_send?"
        if [[ "$?" -eq 0 ]]; then
            if ! curl -sS "$local_send_url" -o "$local_send_deb"; then
                echo_with_color "$RED_COLOR" "Failed to download LocalSend."
            else
                sudo dpkg -i "$local_send_deb"
                rm "$local_send_deb"
                echo_with_color "$GREEN_COLOR" "LocalSend installed successfully."
            fi
        else
            echo_with_color "$GREEN_COLOR" "Skipping LocalSend installation."
        fi
    else
        echo_with_color "$GREEN_COLOR" "LocalSend is already installed."
    fi
}

install_plandex_cli() {
    if ! command_exists "plandex"; then
        echo_with_color "$YELLOW_COLOR" "plandex-cli is not installed."
        ask_yes_or_no "Do you want to install plandex-cli?"
        if [[ "$?" -eq 0 ]]; then
            if ! curl -sS https://plandex.ai/install.sh | bash; then
                echo_with_color "$RED_COLOR" "Failed to install plandex-cli."
            else
                echo_with_color "$GREEN_COLOR" "plandex-cli installed successfully."
            fi
        else
            echo_with_color "$GREEN_COLOR" "Skipping plandex-cli installation."
        fi
    else
        echo_with_color "$GREEN_COLOR" "plandex-cli is already installed."
    fi
}

istall_helix_edtor() {
    if ! command_exists "hx"; then
        echo_with_color "$YELLOW_COLOR" "Helix editor is not installed."
        ask_yes_or_no "Do you want to install Helix editor?"
        if [[ "$?" -eq 0 ]]; then
            echo_with_color "$YELLOW_COLOR" "Installing Helix editor."
            sudo add-apt-repository ppa:maveonair/helix-editor -y || echo_with_color "$RED_COLOR" "Failed to add Helix editor repository."
            sudo apt update || echo_with_color "$RED_COLOR" "Failed to update apt."
            sudo apt install helix -y || echo_with_color "$RED_COLOR" "Failed to install Helix editor."
        else
            echo_with_color "$GREEN_COLOR" "Skipping Helix editor installation."
        fi
    else
        echo_with_color "$GREEN_COLOR" "Helix editor is already installed."
    fi
}

install_supafile() {
    if ! command_exists "spf"; then
        echo_with_color "$YELLOW_COLOR" "supafile is not installed."
        ask_yes_or_no "Do you want to install supafile?"
        if [[ "$?" -eq 0 ]]; then
            if ! bash -c "$(wget -qO- https://superfile.netlify.app/install.sh)"; then
                echo_with_color "$RED_COLOR" "Failed to install supafile."
            else
                echo_with_color "$GREEN_COLOR" "supafile installed successfully."
            fi
        else
            echo_with_color "$GREEN_COLOR" "Skipping supafile installation."
        fi
    else
        echo_with_color "$GREEN_COLOR" "supafile is already installed."
    fi
}

install_oci_cli() {
  if ! command_exists oci; then
    echo_with_color "$YELLOW_COLOR" "Oracle Cloud Infrastructure CLI is not installed."
    ask_yes_or_no "Do you want to install Oracle Cloud Infrastructure CLI?"
    if [[ "$?" -eq 0 ]]; then
      if ! bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"; then
      echo_with_color "$RED_COLOR" "Failed to install Oracle Cloud Infrastructure CLI."
      else
      echo_with_color "$GREEN_COLOR" "Oracle Cloud Infrastructure CLI installed successfully."
      fi
    else
      echo_with_color "$GREEN_COLOR" "Skipping Oracle Cloud Infrastructure CLI installation."
    fi
      else
    echo_with_color "$GREEN_COLOR" "Oracle Cloud Infrastructure CLI is already installed."
      fi
}


# check for dependencies
if ! command_exists "curl"; then
    echo_with_color "$RED_COLOR" "curl is required"
fi

install_local_send
install_plandex_cli
istall_helix_edtor
install_supafile
install_oci_cli

