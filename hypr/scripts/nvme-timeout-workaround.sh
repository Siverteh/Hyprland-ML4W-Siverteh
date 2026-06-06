#!/usr/bin/env bash

set -euo pipefail

ASPM_POLICY="/sys/module/pcie_aspm/parameters/policy"
NVME_APST="/sys/module/nvme_core/parameters/default_ps_max_latency_us"

usage() {
    cat <<'EOF'
Usage:
  nvme-timeout-workaround.sh status
  nvme-timeout-workaround.sh apply
  nvme-timeout-workaround.sh revert

Commands:
  status  Show the current PCIe/NVMe power-management state.
  apply   Set PCIe ASPM policy to performance and disable d3cold for the NVMe path.
  revert  Restore PCIe ASPM policy to default and re-enable d3cold.

If root access is required, the script prints the exact sudo commands to run.
EOF
}

nvme_devices() {
    local path

    for path in /sys/class/nvme/nvme*/device; do
        [[ -e "$path" ]] || continue
        readlink -f "$path"
    done
}

write_value() {
    local path="$1"
    local value="$2"

    [[ -e "$path" && -w "$path" ]] || return 0
    printf '%s\n' "$value" > "$path" || true
}

print_value() {
    local label="$1"
    local path="$2"

    printf '%s=' "$label"
    if [[ -e "$path" ]]; then
        cat "$path"
    else
        printf 'missing\n'
    fi
}

print_status() {
    local dev parent

    print_value pcie_aspm_policy "$ASPM_POLICY"
    print_value nvme_default_ps_max_latency_us "$NVME_APST"

    for dev in $(nvme_devices); do
        parent="$(dirname "$dev")"
        printf 'nvme_device=%s\n' "$dev"
        print_value "${dev}/d3cold_allowed" "${dev}/d3cold_allowed"
        print_value "${dev}/power/control" "${dev}/power/control"
        printf 'nvme_parent=%s\n' "$parent"
        print_value "${parent}/d3cold_allowed" "${parent}/d3cold_allowed"
        print_value "${parent}/power/control" "${parent}/power/control"
    done
}

require_root_for() {
    local mode="$1"

    if (( EUID == 0 )); then
        return 0
    fi

    if [[ "$mode" == "apply" ]]; then
        cat <<EOF
Root access is required to apply the NVMe timeout workaround.

Run:
  sudo ${0} apply

Then check:
  ${0##*/} status
EOF
    else
        cat <<EOF
Root access is required to revert the NVMe timeout workaround.

Run:
  sudo ${0} revert

Then check:
  ${0##*/} status
EOF
    fi

    exit 1
}

apply() {
    local dev parent

    require_root_for apply
    write_value "$ASPM_POLICY" performance
    write_value "$NVME_APST" 0

    for dev in $(nvme_devices); do
        parent="$(dirname "$dev")"
        write_value "${dev}/d3cold_allowed" 0
        write_value "${dev}/power/control" on
        write_value "${parent}/d3cold_allowed" 0
        write_value "${parent}/power/control" on
    done

    print_status
}

revert() {
    local dev parent

    require_root_for revert
    write_value "$ASPM_POLICY" default
    write_value "$NVME_APST" 100000

    for dev in $(nvme_devices); do
        parent="$(dirname "$dev")"
        write_value "${dev}/d3cold_allowed" 1
        write_value "${dev}/power/control" on
        write_value "${parent}/d3cold_allowed" 1
        write_value "${parent}/power/control" auto
    done

    print_status
}

main() {
    case "${1:-status}" in
        status)
            print_status
            ;;
        apply)
            apply
            ;;
        revert)
            revert
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
