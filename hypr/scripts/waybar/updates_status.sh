#!/usr/bin/env bash

set -u

CACHE_DIR="${HOME}/.cache/siverteh"
CACHE_FILE="${CACHE_DIR}/updates-waybar.json"
LOCK_FILE="${CACHE_DIR}/updates-waybar.lock"
SETTINGS_FILE="${HOME}/.config/siverteh/settings.json"
REFRESH_INTERVAL=1800

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

refresh_cache() {
    exec 9>"${LOCK_FILE}"
    flock -n 9 || return 0

    local tmp_file old_content new_content
    tmp_file=$(mktemp)
    old_content=""

    if [ -f "${CACHE_FILE}" ]; then
        old_content=$(cat "${CACHE_FILE}" 2>/dev/null || true)
    fi

    if "${HOME}/.config/siverteh/core/scripts/updates.sh" >"${tmp_file}" 2>/dev/null; then
        new_content=$(cat "${tmp_file}" 2>/dev/null || true)
        mv "${tmp_file}" "${CACHE_FILE}"
        if [ "${new_content}" != "${old_content}" ]; then
            pkill -RTMIN+1 waybar >/dev/null 2>&1 || true
        fi
    else
        rm -f "${tmp_file}"
        return 1
    fi
}

refresh_cache_async() {
    (
        refresh_cache
    ) >/dev/null 2>&1 &
}

cache_is_stale() {
    if [ ! -s "${CACHE_FILE}" ]; then
        return 0
    fi

    local now cache_mtime age
    now=$(date +%s)
    cache_mtime=$(stat -c %Y "${CACHE_FILE}" 2>/dev/null || echo 0)
    age=$((now - cache_mtime))

    [ "${age}" -ge "${REFRESH_INTERVAL}" ]
}

if [ "${1:-}" = "--refresh-now" ]; then
    refresh_cache >/dev/null 2>&1 || exit 1
    exit 0
fi

if [ -s "${CACHE_FILE}" ]; then
    cat "${CACHE_FILE}"
else
    print_placeholder
fi

if cache_is_stale; then
    refresh_cache_async
fi
