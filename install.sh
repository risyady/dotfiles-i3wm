#!/bin/bash

# Color for output text
INFO='\033[0;34m'
SUCCESS='\033[0;32m'
WARN='\033[0;33m'
NC='\033[0m' # No Color

# Directory of sources and marker files
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONFIG_DIR="$HOME/.config"
LOCK_FILE="$HOME/.risyady_dotfiles_installed"

# Configuration list: [source_folder]=“$HOME/.config/[destination_folder]”
declare -A configs
configs=(
    ["i3"]="$CONFIG_DIR/i3"
    ["rofi"]="$CONFIG_DIR/rofi"
    ["picom"]="$CONFIG_DIR/picom"
    # ["alacritty"]="$CONFIG_DIR/alacritty"
)

# --- Controller Parser ---

usage() {
    cat << EOF
Usage: ./install.sh [OPTION]

A script to manage the installation of Risyady's dotfiles.

Options:
  -r, -f, --reinstall, --force    Force reinstall all configurations.
  -u, --uninstall                 Uninstall all configurations and restore backups.
  -h, --help                      Display this help and exit.

If no option is provided, the script will run a fresh installation.
EOF
}

install_or_reinstall() {
    # Loop through each application
    for app in "${!configs[@]}"; do
        source_path="$SOURCE_DIR/$app"
        target_path="${configs[$app]}"

        echo -e "\n${INFO}Processing: $app...${NC}"
        if [ ! -d "$source_path" ]; then
            echo -e "${WARN}Source dir $source_path not found. Skipping.${NC}"; continue;
        fi

        # Backup if there is an original configuration (not a symlink)
        if [ -e "$target_path" ] && [ ! -L "$target_path" ]; then
            echo -e "${WARN}Found existing config at $target_path. Backing up...${NC}"
            rm -rf "$target_path.bak"
            mv "$target_path" "$target_path.bak"
        fi
        
        # Create a symlink, overwrite if it already exists (-f)
        ln -snf "$source_path" "$target_path"
        echo -e "${SUCCESS}Successfully linked $app.${NC}"
    done

    # Check for personal config template and create one if it doesn't exist
    PERSONAL_CONFIG_PATH="$CONFIG_DIR/i3/personal_configs"
    PERSONAL_CONFIG_EXAMPLE_PATH="$SOURCE_DIR/i3/personal_configs.example"

    if [ ! -f "$PERSONAL_CONFIG_PATH" ] && [ -f "$PERSONAL_CONFIG_EXAMPLE_PATH" ]; then
        echo -e "${INFO}Personal config not found. Creating from template...${NC}"
        cp "$PERSONAL_CONFIG_EXAMPLE_PATH" "$PERSONAL_CONFIG_PATH"
        echo -e "${SUCCESS}Created $PERSONAL_CONFIG_PATH. You can add your personal keybindings here.${NC}"
    fi
}

uninstall() {
    echo -e "${WARN}Uninstalling all configurations...${NC}"
    for app in "${!configs[@]}"; do
        target_path="${configs[$app]}"
        echo -e "\n${INFO}Processing: $app...${NC}"
        if [ -L "$target_path" ]; then
            rm "$target_path"
            echo -e "Removed symlink for $app."
            if [ -e "$target_path.bak" ]; then
                mv "$target_path.bak" "$target_path"
                echo -e "Restored backup for $app."
            fi
        else
            echo -e "No symlink found for $app. Skipping."
        fi
    done
    if [ -f "$LOCK_FILE" ]; then rm "$LOCK_FILE"; echo -e "\nRemoved lock file."; fi
    echo -e "\n${SUCCESS}Uninstallation complete!${NC}"
}

# --- MAIN LOGIC ---

case "$1" in
    -r|-f|--reinstall|--force)
        echo -e "${INFO}Forcing reinstallation...${NC}"
        install_or_reinstall
        ;;
    -u|--uninstall)
        uninstall
        ;;
    -h|--help)
        usage
        ;;
    *)
        if [ -f "$LOCK_FILE" ]; then
            echo -e "${SUCCESS}Dotfiles are already installed.${NC}"
            echo "Use --reinstall to force, or --uninstall to remove."
            exit 0
        fi
        echo -e "${INFO}Starting new installation...${NC}"
        install_or_reinstall
        touch "$LOCK_FILE"
        echo -e "\n${SUCCESS}Installation complete! Lock file created.${NC}"
        ;;
esac

echo "Please reload your session (e.g., logout/login or Mod+Shift+r for i3)."