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

# Calculate stats
print_header() {
    local total=$(jq '.achievements | length' "${ACHIEVEMENTS_FILE}")
    local unlocked=$(jq '.achievements | to_entries | map(select(.value.unlocked == true)) | length' "${STATE_FILE}")
    local percent=0
    [[ ${total} -gt 0 ]] && percent=$((unlocked * 100 / total))

    echo ""
    printf "${C_HEADER}${BOLD}  CLAUDE CODE ACHIEVEMENTS${RESET}\n"
    printf "${C_BORDER}╭────────────────────────────────────────────╮${RESET}\n"
    printf "${C_BORDER}│${RESET}"

    # Progress bar with color
    local filled=$((percent / 5))
    local empty=$((20 - filled))
    printf "  ${C_PROGRESS}"
    for ((i=0; i<filled; i++)); do printf "▰"; done
    printf "${C_PROGRESS_BG}"
    for ((i=0; i<empty; i++)); do printf "▱"; done
    printf "${RESET}  ${BOLD}%d${RESET}/${DIM}%d${RESET} ${C_HEADER}%d%%${RESET}   ${C_BORDER}│${RESET}\n" "${unlocked}" "${total}" "${percent}"
    printf "${C_BORDER}╰────────────────────────────────────────────╯${RESET}\n"
    echo ""
}

# Show unlocked achievements only (compact)
show_unlocked() {
    local count=0
    printf "${C_SUCCESS}${BOLD}✓ Unlocked${RESET}\n"
    echo ""

    for id in $(jq -r '.achievements | keys[]' "${ACHIEVEMENTS_FILE}"); do
        if jq -e ".achievements[\"${id}\"].unlocked == true" "${STATE_FILE}" > /dev/null 2>&1; then
            local icon=$(jq -r ".achievements[\"${id}\"].icon // \"🏆\"" "${ACHIEVEMENTS_FILE}")
            local name=$(get_achievement_name "${id}")
            printf "  ${icon} ${name}\n"
            ((count++))
        fi
    done

    if [[ ${count} -eq 0 ]]; then
        printf "  ${DIM}No achievements yet. Start using Claude Code!${RESET}\n"
    fi
    echo ""
}

# Show locked achievements only (with hints)
show_locked() {
    local count=0
    printf "${C_LOCKED}${BOLD}○ Locked${RESET}\n"
    echo ""

    for id in $(jq -r '.achievements | keys[]' "${ACHIEVEMENTS_FILE}"); do
        if ! jq -e ".achievements[\"${id}\"].unlocked == true" "${STATE_FILE}" > /dev/null 2>&1; then
            local icon=$(jq -r ".achievements[\"${id}\"].icon // \"🏆\"" "${ACHIEVEMENTS_FILE}")
            local name=$(get_achievement_name "${id}")
            local desc=$(get_achievement_desc "${id}")
            printf "  ${C_LOCKED}${icon} ${name}${RESET}\n"
            printf "    ${DIM}└─ ${desc}${RESET}\n"
            ((count++))
        fi
    done

    if [[ ${count} -eq 0 ]]; then
        printf "  ${C_SUCCESS}All achievements unlocked! 🎉${RESET}\n"
    fi
    echo ""
}

# Show all achievements grouped by category
show_all() {
    for category in $(jq -r '.categories | to_entries | sort_by(.value.order) | .[].key' "${ACHIEVEMENTS_FILE}"); do
        local category_name=$(jq -r ".categories[\"${category}\"].name // \"${category}\"" "${ACHIEVEMENTS_FILE}")
        local localized_name=$(get_localized ".categories[\"${category}\"].name" "${category_name}")

        printf "${BOLD}${localized_name}${RESET}\n"

        local ids=$(jq -r ".achievements | to_entries | map(select(.value.category == \"${category}\")) | .[].key" "${ACHIEVEMENTS_FILE}")

        for id in ${ids}; do
            local icon=$(jq -r ".achievements[\"${id}\"].icon // \"🏆\"" "${ACHIEVEMENTS_FILE}")
            local name=$(get_achievement_name "${id}")
            local desc=$(get_achievement_desc "${id}")

            if jq -e ".achievements[\"${id}\"].unlocked == true" "${STATE_FILE}" > /dev/null 2>&1; then
                printf "  ${C_SUCCESS}✓${RESET} ${icon} ${name}\n"
            else
                printf "  ${C_LOCKED}○ ${icon} ${name}${RESET}\n"
                printf "    ${DIM}└─ ${desc}${RESET}\n"
            fi
        done
        echo ""
    done
}

# Main
ARG="${1:-unlocked}"

print_header

case "${ARG}" in
    unlocked|done)
        show_unlocked
        ;;
    locked|todo)
        show_locked
        ;;
    all)
        show_all
        ;;
    *)
        # Check if it's a category name
        if jq -e ".categories[\"${ARG}\"]" "${ACHIEVEMENTS_FILE}" > /dev/null 2>&1; then
            local category_name=$(jq -r ".categories[\"${ARG}\"].name // \"${ARG}\"" "${ACHIEVEMENTS_FILE}")
            local localized_name=$(get_localized ".categories[\"${ARG}\"].name" "${category_name}")

            printf "${BOLD}${localized_name}${RESET}\n"

            local ids=$(jq -r ".achievements | to_entries | map(select(.value.category == \"${ARG}\")) | .[].key" "${ACHIEVEMENTS_FILE}")

            for id in ${ids}; do
                local icon=$(jq -r ".achievements[\"${id}\"].icon // \"🏆\"" "${ACHIEVEMENTS_FILE}")
                local name=$(get_achievement_name "${id}")
                local desc=$(get_achievement_desc "${id}")

                if jq -e ".achievements[\"${id}\"].unlocked == true" "${STATE_FILE}" > /dev/null 2>&1; then
                    printf "  ${C_SUCCESS}✓${RESET} ${icon} ${name}\n"
                else
                    printf "  ${C_LOCKED}○ ${icon} ${name}${RESET}\n"
                    printf "    ${DIM}└─ ${desc}${RESET}\n"
                fi
            done
            echo ""
        else
            echo "Usage: /achievements [unlocked|locked|all|<category>]"
            echo ""
            echo "  unlocked  Show unlocked achievements (default)"
            echo "  locked    Show locked achievements with hints"
            echo "  all       Show all achievements by category"
            echo ""
            echo "Categories: basics, workflow, tools, mastery"
        fi
        ;;
esac
