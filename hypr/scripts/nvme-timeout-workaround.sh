#!/usr/bin/env bash

set -euo pipefail

NVME_DEV="10000:e1:00.0"
UPSTREAM_PORT="10000:e0:06.2"
ASPM_POLICY="/sys/module/pcie_aspm/parameters/policy"
NVME_APST="/sys/module/nvme_core/parameters/default_ps_max_latency_us"

paths=(
    "/sys/bus/pci/devices/${NVME_DEV}/d3cold_allowed"
    "/sys/bus/pci/devices/${UPSTREAM_PORT}/d3cold_allowed"
    "/sys/bus/pci/devices/${NVME_DEV}/power/control"
    "/sys/bus/pci/devices/${UPSTREAM_PORT}/power/control"
)

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

print_status() {
    printf 'pcie_aspm_policy='
    cat "$ASPM_POLICY"
    printf 'nvme_default_ps_max_latency_us='
    cat "$NVME_APST"
    printf '%s=' "${paths[0]}"
    cat "${paths[0]}"
    printf '%s=' "${paths[1]}"
    cat "${paths[1]}"
    printf '%s=' "${paths[2]}"
    cat "${paths[2]}"
    printf '%s=' "${paths[3]}"
    cat "${paths[3]}"
}

require_root_for() {
    local mode="$1"

    if [[ -w "$ASPM_POLICY" && -w "$NVME_APST" && -w "${paths[0]}" && -w "${paths[1]}" && -w "${paths[2]}" && -w "${paths[3]}" ]]; then
        return 0
    fi

    if [[ "$mode" == "apply" ]]; then
        cat <<EOF
Root access is required to apply the NVMe timeout workaround.

Run:
  echo performance | sudo tee ${ASPM_POLICY} >/dev/null
  echo 0 | sudo tee ${NVME_APST} >/dev/null
  echo 0 | sudo tee ${paths[0]} >/dev/null
  echo 0 | sudo tee ${paths[1]} >/dev/null
  echo on | sudo tee ${paths[2]} >/dev/null
  echo on | sudo tee ${paths[3]} >/dev/null

Then check:
  ${0##*/} status
EOF
    else
        cat <<EOF
Root access is required to revert the NVMe timeout workaround.

Run:
  echo default | sudo tee ${ASPM_POLICY} >/dev/null
  echo 100000 | sudo tee ${NVME_APST} >/dev/null
  echo 1 | sudo tee ${paths[0]} >/dev/null
  echo 1 | sudo tee ${paths[1]} >/dev/null
  echo on | sudo tee ${paths[2]} >/dev/null
  echo auto | sudo tee ${paths[3]} >/dev/null

Then check:
  ${0##*/} status
EOF
    fi

    exit 1
}

apply() {
    require_root_for apply
    echo performance > "$ASPM_POLICY"
    echo 0 > "$NVME_APST"
    echo 0 > "${paths[0]}"
    echo 0 > "${paths[1]}"
    echo on > "${paths[2]}"
    echo on > "${paths[3]}"
    print_status
}

revert() {
    require_root_for revert
    echo default > "$ASPM_POLICY"
    echo 100000 > "$NVME_APST"
    echo 1 > "${paths[0]}"
    echo 1 > "${paths[1]}"
    echo on > "${paths[2]}"
    echo auto > "${paths[3]}"
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
