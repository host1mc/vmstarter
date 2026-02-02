#!/bin/bash
set -euo pipefail

# Directory where VM configs are stored
VM_DIR="$HOME/vms"

# Colored status output
print_status() {
    local type=$1
    local message=$2
    case $type in
        "INFO") echo -e "\033[1;34m[INFO]\033[0m $message" ;;
        "ERROR") echo -e "\033[1;31m[ERROR]\033[0m $message" ;;
        *) echo "$message" ;;
    esac
}

# Load VM configuration
load_vm_config() {
    local vm_name=$1
    local config_file="$VM_DIR/$vm_name.conf"
    if [[ -f "$config_file" ]]; then
        source "$config_file"
        return 0
    else
        print_status "ERROR" "Config for VM '$vm_name' not found"
        return 1
    fi
}

# Get list of VMs
get_vm_list() {
    find "$VM_DIR" -name "*.conf" -exec basename {} .conf \; 2>/dev/null | sort
}

# Check if VM is running
is_vm_running() {
    local vm_name=$1
    load_vm_config "$vm_name" 2>/dev/null || return 1
    if pgrep -f "qemu-system.*$IMG_FILE" >/dev/null; then
        return 0
    fi
    return 1
}

# Start a VM
start_vm() {
    local vm_name=$1
    if load_vm_config "$vm_name"; then
        if is_vm_running "$vm_name"; then
            print_status "INFO" "VM '$vm_name' is already running"
            return 1
        fi

        print_status "INFO" "Starting VM '$vm_name'..."
        qemu-system-x86_64 \
            -enable-kvm \
            -m "$MEMORY" \
            -smp "$CPUS" \
            -drive "file=$IMG_FILE,format=qcow2,if=virtio" \
            -drive "file=$SEED_FILE,format=raw,if=virtio" \
            -boot order=c \
            -device virtio-net-pci,netdev=n0 \
            -netdev "user,id=n0,hostfwd=tcp::$SSH_PORT-:22" \
            -nographic -serial mon:stdio
    fi
}

# Main menu
main_menu() {
    local vms=($(get_vm_list))
    local count=${#vms[@]}
    echo "Available VMs:"
    for i in "${!vms[@]}"; do
        local status="Stopped"
        if is_vm_running "${vms[$i]}"; then
            status="Running"
        fi
        printf "%2d) %s [%s]\n" $((i+1)) "${vms[$i]}" "$status"
    done

    read -p "Enter VM number to start: " vm_num
    if [[ "$vm_num" =~ ^[0-9]+$ ]] && [ "$vm_num" -ge 1 ] && [ "$vm_num" -le $count ]; then
        start_vm "${vms[$((vm_num-1))]}"
    else
        print_status "ERROR" "Invalid selection"
    fi
}

main_menu
