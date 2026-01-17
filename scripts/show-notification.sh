#!/bin/bash
# show-notification.sh - Display achievement unlock notification
# Usage: show-notification.sh <achievement_id>

set -e

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$0")")}"
STATE_FILE="${HOME}/.claude/achievements/state.json"
ACHIEVEMENTS_FILE="${PLUGIN_ROOT}/data/achievements.json"

# ANSI Color Codes
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

C_HEADER='\033[36m'
C_SUCCESS='\033[32m'
C_BORDER='\033[90m'

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

# Custom icon path for system notifications
CUSTOM_ICON="${PLUGIN_ROOT}/assets/icon.png"

# Get unlock stats
TOTAL=$(jq '.achievements | length' "${ACHIEVEMENTS_FILE}")
UNLOCKED=$(jq '.achievements | to_entries | map(select(.value.unlocked == true)) | length' "${STATE_FILE}")

# Get localized name, description and UI text
I18N_FILE="${PLUGIN_ROOT}/data/i18n/${LANG}.json"
UNLOCKED_TEXT="unlocked"
if [[ -f "${I18N_FILE}" ]]; then
    NAME=$(jq -r ".achievements[\"${ACHIEVEMENT_ID}\"].name // empty" "${I18N_FILE}")
    DESC=$(jq -r ".achievements[\"${ACHIEVEMENT_ID}\"].description // empty" "${I18N_FILE}")
    UNLOCKED_TEXT=$(jq -r '.ui.unlocked_count // "unlocked"' "${I18N_FILE}")
fi

# Fall back to default if no translation
if [[ -z "${NAME}" ]]; then
    NAME=$(jq -r ".achievements[\"${ACHIEVEMENT_ID}\"].name // \"Unknown\"" "${ACHIEVEMENTS_FILE}")
fi
if [[ -z "${DESC}" ]]; then
    DESC=$(jq -r ".achievements[\"${ACHIEVEMENT_ID}\"].description // \"\"" "${ACHIEVEMENTS_FILE}")
fi

show_system_notification() {
    local OS="$(uname -s)"
    local TITLE="${ICON} ${NAME}"
    local BODY="${DESC}"
    local SUBTITLE="${UNLOCKED}/${TOTAL} ${UNLOCKED_TEXT}"

    case "${OS}" in
        Darwin)
            osascript -e "display notification \"${BODY}\" with title \"${TITLE}\" subtitle \"${SUBTITLE}\" sound name \"Glass\"" 2>/dev/null || show_terminal_notification
            ;;
        Linux)
            if command -v notify-send &> /dev/null; then
                # Use custom icon if available
                if [[ -f "${CUSTOM_ICON}" ]]; then
                    notify-send "${TITLE}" "${BODY}\n${SUBTITLE}" -i "${CUSTOM_ICON}" 2>/dev/null || show_terminal_notification
                else
                    notify-send "${TITLE}" "${BODY}\n${SUBTITLE}" -i dialog-information 2>/dev/null || show_terminal_notification
                fi
            else
                show_terminal_notification
            fi
            ;;
        MINGW*|MSYS*|CYGWIN*)
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

show_terminal_notification() {
    {
        echo ""
        printf "${C_BORDER}╭────────────────────────────────────────────╮${RESET}\n"
        printf "${C_BORDER}│${RESET}  ${C_SUCCESS}★${RESET} ${C_HEADER}${BOLD}ACHIEVEMENT UNLOCKED${RESET}                 ${C_BORDER}│${RESET}\n"
        printf "${C_BORDER}├────────────────────────────────────────────┤${RESET}\n"
        printf "${C_BORDER}│${RESET}  ${ICON} ${BOLD}${NAME}${RESET}\n"
        printf "${C_BORDER}│${RESET}  ${DIM}${DESC}${RESET}\n"
        printf "${C_BORDER}│${RESET}  ${BOLD}${UNLOCKED}${RESET}${DIM}/${TOTAL} ${UNLOCKED_TEXT}${RESET}\n"
        printf "${C_BORDER}╰────────────────────────────────────────────╯${RESET}\n"
        echo ""
    } >&2
}

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
