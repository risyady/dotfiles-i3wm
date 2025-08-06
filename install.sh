#!/bin/bash

# Warna untuk output
INFO='\033[0;34m'
SUCCESS='\033[0;32m'
WARN='\033[0;33m'
NC='\033[0m' # No Color

# Direktori sumber dan file penanda
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONFIG_DIR="$HOME/.config"
LOCK_FILE="$HOME/.risyady_dotfiles_installed"

# Daftar konfigurasi: [folder_sumber]="$HOME/.config/[folder_tujuan]"
declare -A configs
configs=(
    ["i3"]="$CONFIG_DIR/i3"
    ["rofi"]="$CONFIG_DIR/rofi"
    # ["alacritty"]="$CONFIG_DIR/alacritty"
    # Tambahkan konfigurasi baru di sini
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
    # Loop melalui setiap aplikasi
    for app in "${!configs[@]}"; do
        source_path="$SOURCE_DIR/$app"
        target_path="${configs[$app]}"

        echo -e "\n${INFO}Processing: $app...${NC}"
        if [ ! -d "$source_path" ]; then
            echo -e "${WARN}Source dir $source_path not found. Skipping.${NC}"; continue;
        fi

        # Backup jika ada konfigurasi asli (bukan symlink)
        if [ -e "$target_path" ] && [ ! -L "$target_path" ]; then
            echo -e "${WARN}Found existing config at $target_path. Backing up...${NC}"
            rm -rf "$target_path.bak"
            mv "$target_path" "$target_path.bak"
        fi
        
        # Buat symlink, timpa jika sudah ada (-f)
        ln -snf "$source_path" "$target_path"
        echo -e "${SUCCESS}Successfully linked $app.${NC}"
    done
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

# --- LOGIKA UTAMA ---

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