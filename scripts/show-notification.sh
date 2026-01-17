#!/bin/bash
# show-notification.sh - Display achievement unlock notification
# Usage: show-notification.sh <achievement_id>

set -e

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$0")")}"
STATE_FILE="${HOME}/.claude/achievements/state.json"
ACHIEVEMENTS_FILE="${PLUGIN_ROOT}/data/achievements.json"

ACHIEVEMENT_ID="$1"

if [[ -z "${ACHIEVEMENT_ID}" ]]; then
    exit 1
fi

# Get user's language preference
LANG=$(jq -r '.settings.language // "en"' "${STATE_FILE}" 2>/dev/null || echo "en")
NOTIFICATIONS_ENABLED=$(jq -r '.settings.notifications // true' "${STATE_FILE}" 2>/dev/null || echo "true")
NOTIFICATION_STYLE=$(jq -r '.settings.notification_style // "system"' "${STATE_FILE}" 2>/dev/null || echo "system")

# Skip if notifications are disabled
if [[ "${NOTIFICATIONS_ENABLED}" == "false" ]]; then
    exit 0
fi

# Get achievement data
ICON=$(jq -r ".achievements[\"${ACHIEVEMENT_ID}\"].icon // \"🏆\"" "${ACHIEVEMENTS_FILE}")
RARITY=$(jq -r ".achievements[\"${ACHIEVEMENT_ID}\"].rarity // \"common\"" "${ACHIEVEMENTS_FILE}")

# Get unlock stats
TOTAL=$(jq '.achievements | length' "${ACHIEVEMENTS_FILE}")
UNLOCKED=$(jq '.achievements | to_entries | map(select(.value.unlocked == true)) | length' "${STATE_FILE}")

# Get localized name
I18N_FILE="${PLUGIN_ROOT}/data/i18n/${LANG}.json"
if [[ -f "${I18N_FILE}" ]]; then
    NAME=$(jq -r ".achievements[\"${ACHIEVEMENT_ID}\"].name // empty" "${I18N_FILE}")
fi

# Fall back to default if no translation
if [[ -z "${NAME}" ]]; then
    NAME=$(jq -r ".achievements[\"${ACHIEVEMENT_ID}\"].name // \"Unknown\"" "${ACHIEVEMENTS_FILE}")
fi

# Rarity display
get_rarity_label() {
    case "$1" in
        common) echo "Common" ;;
        uncommon) echo "Uncommon" ;;
        rare) echo "Rare" ;;
        epic) echo "Epic" ;;
        legendary) echo "Legendary" ;;
        *) echo "Common" ;;
    esac
}

RARITY_LABEL=$(get_rarity_label "${RARITY}")

# Show system notification (cross-platform)
# Check if system notifications are available
check_system_notification_available() {
    local OS="$(uname -s)"
    case "${OS}" in
        Darwin)
            # macOS - osascript is always available
            return 0
            ;;
        Linux)
            # Linux - check for notify-send
            command -v notify-send &> /dev/null && return 0
            return 1
            ;;
        MINGW*|MSYS*|CYGWIN*)
            # Windows - check for powershell
            command -v powershell.exe &> /dev/null && return 0
            return 1
            ;;
        *)
            return 1
            ;;
    esac
}

show_system_notification() {
    local OS="$(uname -s)"
    local TITLE="Achievement Unlocked!"
    local BODY="${ICON} ${NAME}"
    local SUBTITLE="${UNLOCKED}/${TOTAL} unlocked • ${RARITY_LABEL}"

    case "${OS}" in
        Darwin)
            # macOS - use osascript
            osascript -e "display notification \"${BODY}\" with title \"${TITLE}\" subtitle \"${SUBTITLE}\"" 2>/dev/null || show_terminal_notification
            ;;
        Linux)
            # Linux - use notify-send if available
            if command -v notify-send &> /dev/null; then
                notify-send "${TITLE}" "${BODY} - ${SUBTITLE}" -i dialog-information 2>/dev/null || show_terminal_notification
            else
                show_terminal_notification
            fi
            ;;
        MINGW*|MSYS*|CYGWIN*)
            # Windows (Git Bash, MSYS, Cygwin) - use PowerShell toast
            if command -v powershell.exe &> /dev/null; then
                powershell.exe -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('${BODY}', '${TITLE}', 'OK', 'Information')" 2>/dev/null || show_terminal_notification
            else
                show_terminal_notification
            fi
            ;;
        *)
            show_terminal_notification
            ;;
    esac
}

# Show terminal notification
show_terminal_notification() {
    {
        echo ""
        echo "🎮 Achievement Unlocked!"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "   ${ICON} ${NAME}"
        echo "   ${RARITY_LABEL} • ${UNLOCKED}/${TOTAL} unlocked"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
    } >&2
}

# Display notification based on style
case "${NOTIFICATION_STYLE}" in
    system)
        show_system_notification
        ;;
    both)
        show_system_notification
        show_terminal_notification
        ;;
    *)
        show_terminal_notification
        ;;
esac

exit 0
