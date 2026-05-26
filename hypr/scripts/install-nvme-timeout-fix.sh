#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="/home/siverteh/Hyprland-ML4W-Siverteh"
SERVICE_SRC="${REPO_ROOT}/hypr/scripts/nvme-timeout-workaround.service"
SERVICE_DST="/etc/systemd/system/nvme-timeout-workaround.service"
LIMINE_CONF="/etc/default/limine"
PARAM="nvme_core.default_ps_max_latency_us=0"

if (( EUID != 0 )); then
    echo "Run this with sudo:" >&2
    echo "  sudo $0" >&2
    exit 1
fi

if [[ ! -f "$LIMINE_CONF" ]]; then
    echo "Missing $LIMINE_CONF; this installer is for the Limine setup on this laptop." >&2
    exit 1
fi

backup="${LIMINE_CONF}.bak.$(date +%Y%m%d-%H%M%S)"
cp -a "$LIMINE_CONF" "$backup"

if ! grep -Fqw "$PARAM" "$LIMINE_CONF"; then
    printf '\n# Work around Micron 2500 NVMe APST timeouts/freezes on ASUS Zenbook.\n' >> "$LIMINE_CONF"
    printf 'KERNEL_CMDLINE[default]+="%s"\n' "$PARAM" >> "$LIMINE_CONF"
fi

install -Dm644 "$SERVICE_SRC" "$SERVICE_DST"
systemctl daemon-reload
systemctl enable nvme-timeout-workaround.service
systemctl restart nvme-timeout-workaround.service

if command -v limine-update >/dev/null 2>&1; then
    limine-update
else
    echo "limine-update was not found; reboot entries were not regenerated." >&2
    exit 1
fi

echo
echo "Installed NVMe timeout fix."
echo "Backup: $backup"
echo "Reboot, then verify:"
echo "  cat /sys/module/nvme_core/parameters/default_ps_max_latency_us"
echo "Expected: 0"
