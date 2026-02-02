# Function to get all VM names
get_vm_list() {
    find "$VM_DIR" -name "*.conf" -exec basename {} .conf \; 2>/dev/null | sort
}

# Load VM configuration
load_vm_config() {
    local vm_name=$1
    local config_file="$VM_DIR/$vm_name.conf"
    
    if [[ -f "$config_file" ]]; then
        unset VM_NAME OS_TYPE CODENAME IMG_URL HOSTNAME USERNAME PASSWORD
        unset DISK_SIZE MEMORY CPUS SSH_PORT GUI_MODE PORT_FORWARDS IMG_FILE SEED_FILE CREATED
        
        source "$config_file"
        return 0
    else
        print_status "ERROR" "📂 Configuration for VM '$vm_name' not found"
        return 1
    fi
}

# Check if VM is running
is_vm_running() {
    local vm_name=$1
    
    # Check by VM name or image file
    if pgrep -f "qemu-system.*$vm_name" >/dev/null; then
        return 0
    fi
    if load_vm_config "$vm_name" 2>/dev/null; then
        if pgrep -f "qemu-system.*$IMG_FILE" >/dev/null; then
            return 0
        fi
    fi
    
    return 1
}

# Start a VM
start_vm() {
    local vm_name=$1
    
    if load_vm_config "$vm_name"; then
        # Check if image is in use
        if ! check_image_lock "$IMG_FILE" "$vm_name"; then
            print_status "ERROR" "🔒 Cannot start VM: Image file is locked"
            return 1
        fi
        
        # Check if VM already running
        if is_vm_running "$vm_name"; then
            print_status "WARN" "⚠️ VM '$vm_name' is already running"
            return 1
        fi
        
        print_status "INFO" "🚀 Starting VM: $vm_name"
        print_status "INFO" "🔌 SSH: ssh -p $SSH_PORT $USERNAME@localhost"
        
        local qemu_cmd=(
            qemu-system-x86_64
            -enable-kvm
            -m "$MEMORY"
            -smp "$CPUS"
            -cpu host
            -drive "file=$IMG_FILE,format=qcow2,if=virtio"
            -drive "file=$SEED_FILE,format=raw,if=virtio"
            -boot order=c
            -device virtio-net-pci,netdev=n0
            -netdev "user,id=n0,hostfwd=tcp::$SSH_PORT-:22"
        )

        if [[ "$GUI_MODE" == true ]]; then
            qemu_cmd+=(-vga virtio -display gtk,gl=on)
        else
            qemu_cmd+=(-nographic -serial mon:stdio)
        fi

        "${qemu_cmd[@]}"
        print_status "INFO" "🛑 VM $vm_name has been shut down"
    fi
}
