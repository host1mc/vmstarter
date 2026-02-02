#!/bin/bash
set -euo pipefail

# ---------- Colors ----------
GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
RESET="\e[0m"

# ---------- Status printing ----------
print_status() {
    local type=$1
    local message=$2
    case $type in
        INFO) echo -e "${CYAN}[INFO]${RESET} $message" ;;
        SUCCESS) echo -e "${GREEN}[SUCCESS]${RESET} $message" ;;
        WARN) echo -e "${YELLOW}[WARN]${RESET} $message" ;;
        ERROR) echo -e "${YELLOW}[ERROR]${RESET} $message" ;;
        INPUT) echo -e "${CYAN}[INPUT]${RESET} $message" ;;
        *) echo "$message" ;;
    esac
}

# ---------- Display banner ----------
display_banner() {
    clear
    echo -e "${CYAN}██████╗  ██████╗ ██████╗ ███╗   ██╗ ██████╗ ███╗   ██╗"
    echo -e "██╔══██╗██╔═══██╗██╔══██╗████╗  ██║██╔═══██╗████╗  ██║"
    echo -e "██████╔╝██║   ██║██████╔╝██╔██╗ ██║██║   ██║██╔██╗ ██║"
    echo -e "██╔═══╝ ██║   ██║██╔═══╝ ██║╚██╗██║██║   ██║██║╚██╗██║"
    echo -e "██║     ╚██████╔╝██║     ██║ ╚████║╚██████╔╝██║ ╚████║"
    echo -e "╚═╝      ╚═════╝ ╚═╝     ╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═══╝${RESET}"
    echo -e "                       ${YELLOW}vps starter${RESET}"
    echo
}

# ---------- List VMs using your load_vm_config logic ----------
list_vms() {
    VMS=()
    # Try to detect all VMs by checking which configs can be loaded
    # This assumes you have a function `get_all_vm_names` or similar
    # If not, we can simulate it by checking all IMG files or configs
    for vm_name in $(ls /path/to/vm/configs 2>/dev/null); do
        if load_vm_config "$vm_name"; then
            VMS+=("$vm_name")
        fi
    done

    print_status "INFO" "📋 Found ${#VMS[@]} existing VM(s):"
    for i in "${!VMS[@]}"; do
        echo -e "   $((i+1))) ${VMS[$i]} 💤"
    done
    echo -e "\n\n"
}

# ---------- Main menu ----------
main_menu() {
    display_banner
    list_vms

    if [ ${#VMS[@]} -eq 0 ]; then
        print_status "WARN" "No VMs found!"
        exit 0
    fi

    read -p "🎯 [INPUT] 🎯 Enter your choice: " CHOICE

    # Validate input
    if [[ "$CHOICE" =~ ^[0-9]+$ ]] && [ "$CHOICE" -ge 1 ] && [ "$CHOICE" -le ${#VMS[@]} ]; then
        start_vm "${VMS[$((CHOICE-1))]}"
    else
        print_status "ERROR" "Invalid selection!"
    fi
}

# ---------- Start the script ----------
main_menu
