#!/bin/bash
set -euo pipefail

# Directory where VM configs/images are stored
VM_DIR="$HOME/vms"

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

# Function to list VMs
list_vms() {
    local vms=()
    if [[ -d "$VM_DIR" ]]; then
        vms=($(ls "$VM_DIR" | grep '\.conf$' | sed 's/\.conf$//'))
    fi

    if [ ${#vms[@]} -eq 0 ]; then
        echo "No VMs found in $VM_DIR"
        return 1
    fi

    echo "Available VMs:"
    for i in "${!vms[@]}"; do
        printf "  (%d) %s\n" $((i+1)) "${vms[$i]}"
    done

    echo -e "\n\n"
    echo "${vms[@]}"  # Return the array for selection
}

# Function to start selected VM
start_vm() {
    local vm_name="$1"
    # You can call your full start_vm function here
    echo "Starting VM: $vm_name ..."
    # Example placeholder:
    # ./start_vm.sh "$vm_name"
}

# Main
display_banner

vms=($(list_vms))
if [ ${#vms[@]} -eq 0 ]; then
    exit 0
fi

# Prompt for selection
while true; do
    read -p "Enter VM number to start: " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#vms[@]} ]; then
        start_vm "${vms[$((choice-1))]}"
        break
    else
        echo "Invalid selection, try again."
    fi
done
