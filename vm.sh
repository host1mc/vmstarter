#!/bin/bash
set -euo pipefail

# =============================
# ARY123 ASCII Header Function with Colors
# =============================
display_header() {
    clear
    # Colors
    local RED="\033[1;31m"
    local GREEN="\033[1;32m"
    local YELLOW="\033[1;33m"
    local BLUE="\033[1;34m"
    local MAGENTA="\033[1;35m"
    local CYAN="\033[1;36m"
    local RESET="\033[0m"

    cat << EOF

${CYAN}  /$$$$$$  /$$$$$$$  /$$     /$$         /$$    /$$$$$$   /$$$$$$ 
 /$$__  $$| $$__  $$|  $$   /$$/       /$$$$   /$$__  $$ /$$__  $$
| $$  \ $$| $$  \ $$ \  $$ /$$/       |_  $$  |__/  \ $$|__/  \ $$
| $$$$$$$$| $$$$$$$/  \  $$$$/          | $$    /$$$$$$/   /$$$$$/
| $$__  $$| $$__  $$   \  $$/           | $$   /$$____/   |___  $$
| $$  | $$| $$  \ $$    | $$            | $$  | $$       /$$  \ $$
| $$  | $$| $$  | $$    | $$           /$$$$$$| $$$$$$$$|  $$$$$$/
|__/  |__/|__/  |__/    |__/          |______/|________/ \______/ ${RESET}

${YELLOW}                          ARY123${RESET}
${MAGENTA}==============================================================${RESET}

EOF
}

# Directory where VM configs are stored
VM_DIR="$HOME/vms"

# Colored status output
print_status() {
    local type=$1
    local message=$2
    local RED="\033[1;31m"
    local BLUE="\033[1;34m"
    local RESET="\033[0m"

    case $type in
        "INFO") echo -e "${BLUE}[INFO]${RESET} $message" ;;
        "ERROR") echo -e "${RED}[ERROR]${RESET} $message" ;;
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
    display_header

    local vms=($(get_vm_list))
    local count=${#vms[@]}
    
    if [ "$count" -eq 0 ]; then
        print_status "ERROR" "No VMs found in $VM_DIR"
        return
    fi

    local GREEN="\033[1;32m"
    local YELLOW="\033[1;33m"
    local RESET="\033[0m"

    echo -e "${YELLOW}Available VMs:${RESET}"
    for i in "${!vms[@]}"; do
        local status="Stopped"
        local color="$GREEN"
        if is_vm_running "${vms[$i]}"; then
            status="Running"
            color="\033[1;36m"  # Cyan for running
        fi
        printf "%2d) %s [%b%s%b]\n" $((i+1)) "${vms[$i]}" "$color" "$status" "$RESET"
    done

    read -p "Enter VM number to start: " vm_num
    if [[ "$vm_num" =~ ^[0-9]+$ ]] && [ "$vm_num" -ge 1 ] && [ "$vm_num" -le $count ]; then
        start_vm "${vms[$((vm_num-1))]}"
    else
        print_status "ERROR" "Invalid selection"
    fi
}

# Run the menu
main_menu
