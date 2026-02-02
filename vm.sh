#!/bin/bash
set -euo pipefail

# Source your main VM script so all functions (load_vm_config, is_vm_running, start_vm) are available
# Make sure this path is correct — adjust if needed
source "$HOME/vm-manager.sh"

# Colors
GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
RESET="\e[0m"

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

# Collect all VM names using your existing logic
get_vm_list_simplified() {
    VM_NAMES=()
    # Your original get_vm_list returns names (without .conf) — reuse it
    while IFS= read -r vm; do
        VM_NAMES+=("$vm")
    done < <(get_vm_list 2>/dev/null)
}

main() {
    display_banner

    get_vm_list_simplified

    local count=${#VM_NAMES[@]}
    print_status "INFO" "📁 Found $count existing VM(s):"
    
    for i in "${!VM_NAMES[@]}"; do
        printf "   %d) %s 💭\n" $((i+1)) "${VM_NAMES[$i]}"
    done

    echo -e "\n\n"

    read -p "$(print_status "INPUT" "🎯 Enter your choice: ")" choice

    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le $count ]; then
        local selected_vm="${VM_NAMES[$((choice-1))]}"
        start_vm "$selected_vm"
    else
        print_status "ERROR" "Invalid selection!"
        exit 1
    fi
}

main
