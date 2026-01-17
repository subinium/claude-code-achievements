#!/bin/bash
# show-achievements.sh - Display achievements in a clean TUI-style view

set -e

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$0")")}"
STATE_FILE="${HOME}/.claude/achievements/state.json"
ACHIEVEMENTS_FILE="${PLUGIN_ROOT}/data/achievements.json"

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

# Get rarity emoji
get_rarity_emoji() {
    case "$1" in
        common) echo "⬜" ;;
        uncommon) echo "🟩" ;;
        rare) echo "🟦" ;;
        epic) echo "🟪" ;;
        legendary) echo "🟨" ;;
        *) echo "⬜" ;;
    esac
}

# Calculate stats
print_header() {
    local total=$(jq '.achievements | length' "${ACHIEVEMENTS_FILE}")
    local unlocked=$(jq '.achievements | to_entries | map(select(.value.unlocked == true)) | length' "${STATE_FILE}")
    local percent=0
    [[ ${total} -gt 0 ]] && percent=$((unlocked * 100 / total))

    echo ""
    echo "🎮 CLAUDE CODE ACHIEVEMENTS"
    echo "┌────────────────────────────────────────────────────────┐"
    echo "│"

    # Progress bar
    local filled=$((percent / 5))
    local empty=$((20 - filled))
    printf "│   "
    for ((i=0; i<filled; i++)); do printf "█"; done
    for ((i=0; i<empty; i++)); do printf "░"; done
    printf "  %d/%d unlocked (%d%%)\n" "${unlocked}" "${total}" "${percent}"
    echo "│"
}

# Show achievements for a category
show_category() {
    local category="$1"
    local category_name=$(jq -r ".categories[\"${category}\"].name // \"${category}\"" "${ACHIEVEMENTS_FILE}")
    local localized_name=$(get_localized ".categories[\"${category}\"].name" "${category_name}")

    echo "├── ${localized_name} ─────────────────────────────────────"
    echo "│"

    # Get achievements in this category
    local ids=$(jq -r ".achievements | to_entries | map(select(.value.category == \"${category}\")) | .[].key" "${ACHIEVEMENTS_FILE}")

    for id in ${ids}; do
        local icon=$(jq -r ".achievements[\"${id}\"].icon // \"🏆\"" "${ACHIEVEMENTS_FILE}")
        local rarity=$(jq -r ".achievements[\"${id}\"].rarity // \"common\"" "${ACHIEVEMENTS_FILE}")
        local rarity_emoji=$(get_rarity_emoji "${rarity}")
        local name=$(get_achievement_name "${id}")
        local desc=$(get_achievement_desc "${id}")

        local unlocked="false"
        if jq -e ".achievements[\"${id}\"].unlocked == true" "${STATE_FILE}" > /dev/null 2>&1; then
            unlocked="true"
        fi

        if [[ "${unlocked}" == "true" ]]; then
            echo "│   ✅ ${icon} ${name} ${rarity_emoji}"
        else
            echo "│   ⬛ ${icon} ${name} ${rarity_emoji}"
            echo "│        ↳ ${desc}"
        fi
    done
    echo "│"
}

# Show rarity legend
show_legend() {
    echo "├────────────────────────────────────────────────────────┤"
    echo "│  ⬜ Common  🟩 Uncommon  🟦 Rare  🟪 Epic  🟨 Legendary"
    echo "└────────────────────────────────────────────────────────┘"
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
