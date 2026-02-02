#!/bin/bash

# Load VM config
load_vm_config() {
    local vm_name=$1
    local config_file="$VM_DIR/$vm_name.conf"

    if [[ ! -f "$config_file" ]]; then
        return 1
    fi

    # shellcheck source=/dev/null
    source "$config_file"
    return 0
}

# Function to get all VM names (from config files)
get_vm_list() {
    find "$VM_DIR" -maxdepth 1 -name "*.conf" -exec basename {} .conf \; 2>/dev/null | sort
}

# Function to check if VM is running
is_vm_running() {
    local vm_name=$1
    
    # Load VM config to get image file path
    if load_vm_config "$vm_name" 2>/dev/null; then
        # Check for any QEMU process using this VM image
        if pgrep -f "qemu-system.*$IMG_FILE" >/dev/null; then
            return 0  # running
        fi
    fi
    
    return 1  # stopped
}

# Function to display VM list with running status
list_vms_with_status() {
    local vms=($(get_vm_list))
    
    if [ ${#vms[@]} -eq 0 ]; then
        echo "📂 No VMs found in $VM_DIR"
        return
    fi
    
    echo "📁 Found ${#vms[@]} VM(s):"
    echo "----------------------------------------"
    for vm_name in "${vms[@]}"; do
        if is_vm_running "$vm_name"; then
            status="🚀 Running"
        else
            status="💤 Stopped"
        fi
        echo "🔹 $vm_name - $status"
    done
    echo "----------------------------------------"
}

# Function to start a VM
start_vm() {
    local vm_name=$1

    if load_vm_config "$vm_name"; then
        if is_vm_running "$vm_name"; then
            echo "⚠️ VM '$vm_name' is already running"
            return 1
        fi

        echo "🚀 Starting VM '$vm_name'..."
        
        # QEMU command using config variables
        qemu-system-x86_64 \
            -enable-kvm \
            -m "$MEMORY" \
            -smp "$CPUS" \
            -cpu host \
            -drive "file=$IMG_FILE,format=qcow2,if=virtio" \
            -drive "file=$SEED_FILE,format=raw,if=virtio" \
            -boot order=c \
            -device virtio-net-pci,netdev=n0 \
            -netdev "user,id=n0,hostfwd=tcp::$SSH_PORT-:22" \
            -nographic -serial mon:stdio
    else
        echo "❌ VM config for '$vm_name' not found."
        return 1
    fi
}

# --- Interactive Menu ---
echo "📂 Listing all VMs with status..."
list_vms_with_status

echo
read -rp "Enter the VM name you want to start: " vm_to_start
start_vm "$vm_to_start"
