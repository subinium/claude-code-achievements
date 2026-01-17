#!/bin/bash
# track-stop.sh - Track Stop hook for ralph-loop iterations
# Called when a conversation ends or is interrupted

set -e

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$0")")}"
STATE_DIR="${HOME}/.claude/achievements"
STATE_FILE="${STATE_DIR}/state.json"

# Check if state file exists
if [[ ! -f "${STATE_FILE}" ]]; then
    exit 0
fi

# Read input from stdin
INPUT=$(cat)
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')

# Increment ralph iterations if ralph-loop is active
# This is detected by checking if the session has ralph_loop_active flag
RALPH_ACTIVE=$(jq -r '.session.ralph_loop_active // false' "${STATE_FILE}")

if [[ "${RALPH_ACTIVE}" == "true" ]]; then
    # Increment counter
    temp_file=$(mktemp)
    jq '.counters.ralph_iterations = (.counters.ralph_iterations // 0) + 1' "${STATE_FILE}" > "${temp_file}"
    mv "${temp_file}" "${STATE_FILE}"

    # Check if threshold reached
    RALPH_COUNT=$(jq -r '.counters.ralph_iterations' "${STATE_FILE}")
    if [[ "${RALPH_COUNT}" -ge 100 ]]; then
        # Check if already unlocked
        if ! jq -e '.achievements["ralph_master"].unlocked == true' "${STATE_FILE}" > /dev/null 2>&1; then
            "${PLUGIN_ROOT}/scripts/show-notification.sh" "ralph_master"
            temp_file=$(mktemp)
            timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
            jq ".achievements[\"ralph_master\"] = {\"unlocked\": true, \"unlockedAt\": \"${timestamp}\"}" "${STATE_FILE}" > "${temp_file}"
            mv "${temp_file}" "${STATE_FILE}"
        fi
    fi
fi

# Check for marketplace plugin installation (plugin_installer achievement)
# /plugin command installs plugins internally without using Write tool
SETTINGS_FILE="${HOME}/.claude/settings.json"
if [[ -f "${SETTINGS_FILE}" ]]; then
    # Check if any @claude-plugins-official plugin is installed
    if grep -q '@claude-plugins-official' "${SETTINGS_FILE}" 2>/dev/null; then
        # Check if not already unlocked
        if ! jq -e '.achievements["plugin_installer"].unlocked == true' "${STATE_FILE}" > /dev/null 2>&1; then
            # Get language preference
            LANG_PREF=$(jq -r '.settings.language // "en"' "${STATE_FILE}" 2>/dev/null || echo "en")

            # Determine trigger message based on language
            case "${LANG_PREF}" in
                ko) TRIGGER_MSG="마켓플레이스에서 플러그인 설치" ;;
                zh) TRIGGER_MSG="从市场安装插件" ;;
                ja) TRIGGER_MSG="マーケットプレイスからプラグインをインストール" ;;
                es) TRIGGER_MSG="Plugin instalado desde marketplace" ;;
                *) TRIGGER_MSG="Installed plugin from marketplace" ;;
            esac

            "${PLUGIN_ROOT}/scripts/show-notification.sh" "plugin_installer" "${TRIGGER_MSG}"
            temp_file=$(mktemp)
            timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
            jq ".achievements[\"plugin_installer\"] = {\"unlocked\": true, \"unlockedAt\": \"${timestamp}\"}" "${STATE_FILE}" > "${temp_file}"
            mv "${temp_file}" "${STATE_FILE}"
        fi
    fi
fi

exit 0
