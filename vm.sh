#!/bin/bash
set -euo pipefail

# Color codes
GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
RESET="\e[0m"

# Function to display banner
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

# Function to list VMs
list_vms() {
    # Replace this with your real VM listing command
    # Example: virsh list --all | tail -n +3 | awk '{print $2}' 
    VMS=($(ls /home/endevil/vms))  # <-- example path; replace as needed

    echo -e "📋 ${GREEN}[INFO]${RESET} 📁 Found ${#VMS[@]} existing VM(s):"
    for i in "${!VMS[@]}"; do
        echo -e "   $((i+1))) ${VMS[$i]} 💤"
    done

    echo -e "\n\n"
}

# Function to start VM
start_vm() {
    VM="${1}"
    echo -e "\n🚀 Starting VM: ${GREEN}$VM${RESET} ..."
    # Replace below with actual start command
    # Example: virsh start "$VM"
    sleep 1  # simulate startup
    echo -e "✅ VM ${GREEN}$VM${RESET} started!"
}

# Main
display_banner
list_vms

read -p "🎯 [INPUT] 🎯 Enter your choice: " CHOICE

# Validate input
if [[ "$CHOICE" =~ ^[0-9]+$ ]] && [ "$CHOICE" -ge 1 ] && [ "$CHOICE" -le ${#VMS[@]} ]; then
    start_vm "${VMS[$((CHOICE-1))]}"
else
    echo -e "${YELLOW}[ERROR] Invalid selection!${RESET}"
fi
