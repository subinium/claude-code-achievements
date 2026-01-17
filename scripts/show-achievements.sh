#!/bin/bash
# show-achievements.sh - Display achievements in a clean TUI-style view

set -e

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$0")")}"
STATE_FILE="${HOME}/.claude/achievements/state.json"
ACHIEVEMENTS_FILE="${PLUGIN_ROOT}/data/achievements.json"

# ANSI Color Codes
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

# Rarity colors
C_COMMON='\033[37m'        # White/Gray
C_UNCOMMON='\033[32m'      # Green
C_RARE='\033[34m'          # Blue
C_EPIC='\033[35m'          # Magenta/Purple
C_LEGENDARY='\033[33m'     # Yellow/Gold

# UI colors
C_HEADER='\033[36m'        # Cyan
C_SUCCESS='\033[32m'       # Green
C_LOCKED='\033[90m'        # Dark gray
C_BORDER='\033[90m'        # Dark gray
C_PROGRESS='\033[36m'      # Cyan
C_PROGRESS_BG='\033[90m'   # Dark gray

# Initialize state if needed
if [[ ! -f "${STATE_FILE}" ]]; then
    mkdir -p "$(dirname "${STATE_FILE}")"
    cat > "${STATE_FILE}" << 'EOF'
{
  "settings": { "language": "en", "notifications": true, "notification_style": "system" },
  "achievements": {},
  "counters": { "ralph_iterations": 0 },
  "session": { "files_read_set": [] }
}
EOF
fi

# Get user's language preference
LANG=$(jq -r '.settings.language // "en"' "${STATE_FILE}")
I18N_FILE="${PLUGIN_ROOT}/data/i18n/${LANG}.json"

# Function to get localized text
get_localized() {
    local key="$1"
    local fallback="$2"
    local result=""
    if [[ -f "${I18N_FILE}" ]]; then
        result=$(jq -r "${key} // empty" "${I18N_FILE}" 2>/dev/null)
    fi
    if [[ -z "${result}" || "${result}" == "null" ]]; then
        echo "${fallback}"
    else
        echo "${result}"
    fi
}

get_achievement_name() {
    local id="$1"
    get_localized ".achievements[\"${id}\"].name" "$(jq -r ".achievements[\"${id}\"].name" "${ACHIEVEMENTS_FILE}")"
}

get_achievement_desc() {
    local id="$1"
    get_localized ".achievements[\"${id}\"].description" "$(jq -r ".achievements[\"${id}\"].description" "${ACHIEVEMENTS_FILE}")"
}

# Get rarity color and label
get_rarity_color() {
    case "$1" in
        common) echo "${C_COMMON}" ;;
        uncommon) echo "${C_UNCOMMON}" ;;
        rare) echo "${C_RARE}" ;;
        epic) echo "${C_EPIC}" ;;
        legendary) echo "${C_LEGENDARY}" ;;
        *) echo "${C_COMMON}" ;;
    esac
}

get_rarity_label() {
    case "$1" in
        common) echo "COMMON" ;;
        uncommon) echo "UNCOMMON" ;;
        rare) echo "RARE" ;;
        epic) echo "EPIC" ;;
        legendary) echo "LEGENDARY" ;;
        *) echo "COMMON" ;;
    esac
}

# Calculate stats
print_header() {
    local total=$(jq '.achievements | length' "${ACHIEVEMENTS_FILE}")
    local unlocked=$(jq '.achievements | to_entries | map(select(.value.unlocked == true)) | length' "${STATE_FILE}")
    local percent=0
    [[ ${total} -gt 0 ]] && percent=$((unlocked * 100 / total))

    echo ""
    printf "${C_HEADER}${BOLD}  CLAUDE CODE ACHIEVEMENTS${RESET}\n"
    printf "${C_BORDER}╭──────────────────────────────────────────────────────────╮${RESET}\n"
    printf "${C_BORDER}│${RESET}"

    # Progress bar with color
    local filled=$((percent / 5))
    local empty=$((20 - filled))
    printf "   ${C_PROGRESS}"
    for ((i=0; i<filled; i++)); do printf "▰"; done
    printf "${C_PROGRESS_BG}"
    for ((i=0; i<empty; i++)); do printf "▱"; done
    printf "${RESET}  ${BOLD}%d${RESET}/${DIM}%d${RESET} unlocked ${C_HEADER}%d%%${RESET}          ${C_BORDER}│${RESET}\n" "${unlocked}" "${total}" "${percent}"
    printf "${C_BORDER}│${RESET}\n"
}

# Show achievements for a category
show_category() {
    local category="$1"
    local category_name=$(jq -r ".categories[\"${category}\"].name // \"${category}\"" "${ACHIEVEMENTS_FILE}")
    local localized_name=$(get_localized ".categories[\"${category}\"].name" "${category_name}")

    printf "${C_BORDER}├─${RESET} ${BOLD}${localized_name}${RESET} ${C_BORDER}────────────────────────────────────────────${RESET}\n"
    printf "${C_BORDER}│${RESET}\n"

    # Get achievements in this category
    local ids=$(jq -r ".achievements | to_entries | map(select(.value.category == \"${category}\")) | .[].key" "${ACHIEVEMENTS_FILE}")

    for id in ${ids}; do
        local icon=$(jq -r ".achievements[\"${id}\"].icon // \"🏆\"" "${ACHIEVEMENTS_FILE}")
        local rarity=$(jq -r ".achievements[\"${id}\"].rarity // \"common\"" "${ACHIEVEMENTS_FILE}")
        local rarity_color=$(get_rarity_color "${rarity}")
        local rarity_label=$(get_rarity_label "${rarity}")
        local name=$(get_achievement_name "${id}")
        local desc=$(get_achievement_desc "${id}")

        local unlocked="false"
        if jq -e ".achievements[\"${id}\"].unlocked == true" "${STATE_FILE}" > /dev/null 2>&1; then
            unlocked="true"
        fi

        if [[ "${unlocked}" == "true" ]]; then
            printf "${C_BORDER}│${RESET}   ${C_SUCCESS}✓${RESET} ${icon} ${BOLD}${name}${RESET}  ${rarity_color}${rarity_label}${RESET}\n"
        else
            printf "${C_BORDER}│${RESET}   ${C_LOCKED}○ ${icon} ${name}  ${rarity_label}${RESET}\n"
            printf "${C_BORDER}│${RESET}     ${DIM}└─ ${desc}${RESET}\n"
        fi
    done
    printf "${C_BORDER}│${RESET}\n"
}

# Show rarity legend
show_legend() {
    printf "${C_BORDER}├──────────────────────────────────────────────────────────┤${RESET}\n"
    printf "${C_BORDER}│${RESET}  ${C_COMMON}■ COMMON${RESET}  ${C_UNCOMMON}■ UNCOMMON${RESET}  ${C_RARE}■ RARE${RESET}  ${C_EPIC}■ EPIC${RESET}  ${C_LEGENDARY}■ LEGENDARY${RESET}  ${C_BORDER}│${RESET}\n"
    printf "${C_BORDER}╰──────────────────────────────────────────────────────────╯${RESET}\n"
    echo ""
}

# Main
ARG="${1:-all}"

print_header

case "${ARG}" in
    stats)
        show_legend
        ;;
    all)
        for category in $(jq -r '.categories | to_entries | sort_by(.value.order) | .[].key' "${ACHIEVEMENTS_FILE}"); do
            show_category "${category}"
        done
        show_legend
        ;;
    *)
        if jq -e ".categories[\"${ARG}\"]" "${ACHIEVEMENTS_FILE}" > /dev/null 2>&1; then
            show_category "${ARG}"
            show_legend
        else
            echo "Unknown: ${ARG}"
            echo "Available: basics, workflow, tools, mastery"
        fi
        ;;
esac
