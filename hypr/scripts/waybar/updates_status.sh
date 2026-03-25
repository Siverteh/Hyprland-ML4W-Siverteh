#!/usr/bin/env bash

set -u

CACHE_DIR="${HOME}/.cache/siverteh"
CACHE_FILE="${CACHE_DIR}/updates-waybar.json"
LOCK_FILE="${CACHE_DIR}/updates-waybar.lock"
SETTINGS_FILE="${HOME}/.config/siverteh/settings.json"

mkdir -p "${CACHE_DIR}"

get_visibility() {
    local visibility="always"
    if [ -f "${SETTINGS_FILE}" ] && command -v jq >/dev/null 2>&1; then
        visibility=$(jq -r '.bar.updates_visibility // "always"' "${SETTINGS_FILE}" 2>/dev/null || echo "always")
    fi
    printf '%s' "${visibility}"
}

print_placeholder() {
    local visibility
    visibility=$(get_visibility)
    if [ "${visibility}" = "pending_only" ]; then
        printf '{"text": "", "alt": "0", "tooltip": "Checking for updates", "class": "neutral"}'
    else
        printf '{"text": "0", "alt": "0", "tooltip": "Checking for updates", "class": "neutral"}'
    fi
}

refresh_cache_async() {
    (
        exec 9>"${LOCK_FILE}"
        flock -n 9 || exit 0

        local tmp_file
        tmp_file=$(mktemp)

        if "${HOME}/.config/ml4w/scripts/updates.sh" >"${tmp_file}" 2>/dev/null; then
            mv "${tmp_file}" "${CACHE_FILE}"
            pkill -RTMIN+1 waybar >/dev/null 2>&1 || true
        else
            rm -f "${tmp_file}"
        fi
    ) >/dev/null 2>&1 &
}

if [ -s "${CACHE_FILE}" ]; then
    cat "${CACHE_FILE}"
else
    print_placeholder
fi

refresh_cache_async
