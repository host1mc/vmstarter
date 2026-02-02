#!/bin/bash
VM_DIR="${VM_DIR:-$HOME/vms}"

get_vm_list() {
    # just list directory names or VM config files (adjust as needed)
    for f in "$VM_DIR"/*; do
        [[ -d "$f" ]] && echo "$(basename "$f")"
    done
}

is_vm_running() {
    local vm="$1"
    # dummy check: replace with your real function
    pgrep -f "$vm" >/dev/null
}

start_vm() {
    local vm="$1"
    echo "🚀 Starting VM: $vm"
    # call your existing start_vm function here
    "$HOME/vm-manager.sh" start_vm "$vm"
}

# Display menu
vms=($(get_vm_list))
if [ ${#vms[@]} -eq 0 ]; then
    echo "📋 [INFO] No VMs found in $VM_DIR"
    exit 1
fi

echo "📋 [INFO] 📁 Found ${#vms[@]} existing VM(s):"
for i in "${!vms[@]}"; do
    status="💤"
    is_vm_running "${vms[$i]}" && status="🚀"
    printf "  %d) %s %s\n" $((i+1)) "${vms[$i]}" "$status"
done

echo
read -p "🎯 Enter VM number to start: " choice

if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#vms[@]} ]; then
    start_vm "${vms[$((choice-1))]}"
else
    echo "❌ Invalid selection"
fi
