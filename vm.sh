#!/bin/bash
set -euo pipefail

# Function to display banner
display_banner() {
    clear
    echo "██████╗  ██████╗ ██████╗ ███╗   ██╗ ██████╗ ███╗   ██╗"
    echo "██╔══██╗██╔═══██╗██╔══██╗████╗  ██║██╔═══██╗████╗  ██║"
    echo "██████╔╝██║   ██║██████╔╝██╔██╗ ██║██║   ██║██╔██╗ ██║"
    echo "██╔═══╝ ██║   ██║██╔═══╝ ██║╚██╗██║██║   ██║██║╚██╗██║"
    echo "██║     ╚██████╔╝██║     ██║ ╚████║╚██████╔╝██║ ╚████║"
    echo "╚═╝      ╚═════╝ ╚═╝     ╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═══╝"
    echo "                       vps starter"
    echo
}

# Function to list all VMs using your original method
list_vms() {
    # Replace the following command with your actual VM list command
    # Example: virsh list --all | tail -n +3 | awk '{print $2}' 
    VMS=($(ls /home/endevil/vms))  # <-- replace this with your exact VM listing command

    if [ ${#VMS[@]} -eq 0 ]; then
        echo "No VMs found!"
        exit 1
    fi

    echo "Available VMs:"
    for i in "${!VMS[@]}"; do
        echo "  ($((i+1))) ${VMS[$i]}"
    done

    echo -e "\n\n"  # two empty lines before prompt
}

# Function to start a VM (replace with your start command)
start_vm() {
    VM="${1}"
    echo "Starting VM: $VM ..."
    # Replace below with actual command to start VM
    # Example: virsh start "$VM"
    sleep 1  # simulate startup
    echo "VM $VM started!"
}

# Main
display_banner
list_vms

read -p "Enter the VM number to start: " CHOICE

# Validate input
if [[ "$CHOICE" =~ ^[0-9]+$ ]] && [ "$CHOICE" -ge 1 ] && [ "$CHOICE" -le ${#VMS[@]} ]; then
    start_vm "${VMS[$((CHOICE-1))]}"
else
    echo "Invalid selection!"
fi
