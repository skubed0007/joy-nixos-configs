#!/usr/bin/env bash

BOLD="\033[1m"
DIM="\033[2m"
RESET="\033[0m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
BLUE="\033[34m"

has_sudo_privs() {
    # Check if sudo access is granted by attempting to create a test file in /root
    echo "test" | sudo tee /root/testfile >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        sudo rm /root/testfile
        return 0
    else
        return 1
    fi
}

copy_config_files_with_sudo() {
    echo -e "\n${CYAN}→ Copying NixOS configuration files with sudo...${RESET}"
    sudo cp ./configuration.nix /etc/nixos/configuration.nix >/dev/null 2>&1
    sudo cp ./nvidia.nix /etc/nixos/nvidia.nix >/dev/null 2>&1
    echo -e "  ${DIM}configuration.nix → /etc/nixos/${RESET}"
    echo -e "  ${DIM}nvidia.nix        → /etc/nixos/${RESET}"
}

copy_config_files_without_sudo() {
    echo -e "\n${CYAN}→ Copying Home Manager configuration files...${RESET}"
    cp -r ./fish ~/.config/fish >/dev/null 2>&1
    cp -r ./omf ~/.config/omf >/dev/null 2>&1
    cp -r ./home.nix ~/.config/home-manager/home.nix >/dev/null 2>&1
    cp -r ./plank ~/.config/plank/
    echo -e "  ${DIM}fish/             → ~/.config/fish/${RESET}"
    echo -e "  ${DIM}omf/              → ~/.config/omf/${RESET}"
    echo -e "  ${DIM}home.nix          → ~/.config/home-manager/${RESET}"
    echo -e "  ${DIM}plank             → ~/.config/plank/${RESET}"
}

end_success() {
    echo -e "\n${GREEN}${BOLD}✅ Setup completed successfully!${RESET}"
}

end_failure() {
    echo -e "\n${RED}${BOLD}❌ Error: Setup failed.${RESET}"
}

run_command_as_user() {
    local username=$1
    shift
    echo -e "${CYAN}→ Running command as user ${username}...${RESET}"
    sudo -u "$username" "$@" >/dev/null 2>&1
}

start_setup() {
    echo -e "\n${BLUE}${BOLD}🚀 Starting setup...${RESET}"
    echo -e "${YELLOW}🔐 Checking sudo access...${RESET}"
}

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --nix)
            ACTION="nix"
            ;;
        --home)
            ACTION="home"
            ;;
        *)
            echo -e "${RED}❌ Error: Invalid argument $1${RESET}"
            exit 1
            ;;
    esac
    shift
done

if [[ "$ACTION" == "nix" ]]; then
    start_setup

    if has_sudo_privs; then
        echo -e "${GREEN}✓ Sudo access granted.${RESET}"
        copy_config_files_with_sudo
        echo -e "\n${CYAN}→ Running nixos-rebuild switch...${RESET}"
        nixos-rebuild switch
        end_success
    else
        echo -e "${RED}❌ Error: No sudo privileges. Setup failed.${RESET}"
        exit 1
    fi
elif [[ "$ACTION" == "home" ]]; then
    start_setup
    copy_config_files_without_sudo
    home-manager switch
    echo -e "${CYAN}→ Home Manager setup completed!${RESET}"
    end_success
else
    echo -e "${RED}❌ Error: No valid action specified. Use --nix or --home.${RESET}"
    exit 1
fi

