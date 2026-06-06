#!/usr/bin/env bash

set -euo pipefail

# ASUS Zenbook 14 UX3405CA touchpad controller discovered locally:
# /devices/pci0000:00/0000:00:15.1/.../i2c-ASUP1415:00
CONTROLLER="0000:00:15.1"
POWER_CONTROL="/sys/bus/pci/devices/${CONTROLLER}/power/control"
RUNTIME_STATUS="/sys/bus/pci/devices/${CONTROLLER}/power/runtime_status"

usage() {
    cat <<'EOF'
Usage:
  touchpad-i2c-runtime-pm.sh status
  touchpad-i2c-runtime-pm.sh on
  touchpad-i2c-runtime-pm.sh auto

Commands:
  status  Show the current runtime PM state for the touchpad's I2C controller.
  on      Disable runtime PM for the controller.
  auto    Re-enable runtime PM for the controller.

If root access is required, the script prints the exact sudo command to run.
EOF
}

print_status() {
    printf 'controller=%s\n' "$CONTROLLER"
    printf 'power_control='
    cat "$POWER_CONTROL"
    printf 'runtime_status='
    cat "$RUNTIME_STATUS"
}

require_writable() {
    local target_state="$1"

    if [[ -w "$POWER_CONTROL" ]]; then
        return 0
    fi

    cat <<EOF
Root access is required to change this controller's power policy.

Run this test command:
  echo ${target_state} | sudo tee ${POWER_CONTROL} >/dev/null

Then re-check with:
  ${0##*/} status
EOF
    exit 1
}

main() {
    local command="${1:-status}"

    case "$command" in
        status)
            print_status
            ;;
        on|auto)
            require_writable "$command"
            echo "$command" > "$POWER_CONTROL"
            print_status
            ;;
        -h|--help|help)
            usage
            ;;
        *)
            usage >&2
            exit 2
            ;;
    esac
}

main "${1:-status}"
