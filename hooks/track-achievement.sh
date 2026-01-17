#!/bin/bash
# track-achievement.sh - Main achievement tracking logic for PostToolUse hook
# Receives JSON via stdin with tool_name, tool_input, and permission_mode

set -e

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$0")")}"
STATE_DIR="${HOME}/.claude/achievements"
STATE_FILE="${STATE_DIR}/state.json"
ACHIEVEMENTS_FILE="${PLUGIN_ROOT}/data/achievements.json"

# Initialize state file if it doesn't exist
init_state() {
    mkdir -p "${STATE_DIR}"
    if [[ ! -f "${STATE_FILE}" ]]; then
        cat > "${STATE_FILE}" << 'EOF'
{
  "settings": { "language": "en", "notifications": true, "notification_style": "system" },
  "achievements": {},
  "counters": { "ralph_iterations": 0 },
  "session": { "files_read_set": [] }
}
EOF
    fi
}

# Read input from stdin
read_input() {
    INPUT=$(cat)
    TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
    TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // {}')
    PERMISSION_MODE=$(echo "$INPUT" | jq -r '.permission_mode // "default"')
}

# Check if achievement is already unlocked
is_unlocked() {
    local achievement_id="$1"
    jq -e ".achievements[\"${achievement_id}\"].unlocked == true" "${STATE_FILE}" > /dev/null 2>&1
}

# Unlock an achievement
unlock_achievement() {
    local achievement_id="$1"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local temp_file=$(mktemp)
    jq ".achievements[\"${achievement_id}\"] = {\"unlocked\": true, \"unlockedAt\": \"${timestamp}\"}" "${STATE_FILE}" > "${temp_file}"
    mv "${temp_file}" "${STATE_FILE}"
    "${PLUGIN_ROOT}/scripts/show-notification.sh" "${achievement_id}"
}

# Check and unlock achievements based on tool use
check_achievements() {
    # Plan mode achievement
    if [[ "${PERMISSION_MODE}" == "plan" ]]; then
        if ! is_unlocked "plan_mode_user"; then
            unlock_achievement "plan_mode_user"
        fi
    fi

    case "${TOOL_NAME}" in
        Write)
            # first_write
            if ! is_unlocked "first_write"; then
                unlock_achievement "first_write"
            fi

            FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty')

            # claude_md_creator (project level)
            if [[ "${FILE_PATH}" =~ CLAUDE\.md$ ]] && [[ ! "${FILE_PATH}" =~ ^${HOME}/\.claude/ ]]; then
                if ! is_unlocked "claude_md_creator"; then
                    unlock_achievement "claude_md_creator"
                fi
            fi

            # global_curator (global ~/.claude/CLAUDE.md)
            if [[ "${FILE_PATH}" =~ ^${HOME}/\.claude/CLAUDE\.md$ ]]; then
                if ! is_unlocked "global_curator"; then
                    unlock_achievement "global_curator"
                fi
            fi

            # config_modifier
            if [[ "${FILE_PATH}" =~ \.claude/settings.*\.json$ ]]; then
                if ! is_unlocked "config_modifier"; then
                    unlock_achievement "config_modifier"
                fi
            fi

            # security_guard (permissions in settings)
            if [[ "${FILE_PATH}" =~ \.claude/settings.*\.json$ ]]; then
                if [[ -f "${FILE_PATH}" ]]; then
                    if grep -qE '"(allowedTools|disallowedTools|permissions)"' "${FILE_PATH}" 2>/dev/null; then
                        if ! is_unlocked "security_guard"; then
                            unlock_achievement "security_guard"
                        fi
                    fi
                fi
            fi

            # hooks_user (hooks in settings or hooks.json)
            if [[ "${FILE_PATH}" =~ hooks\.json$ ]] || [[ "${FILE_PATH}" =~ \.claude/settings.*\.json$ ]]; then
                if [[ -f "${FILE_PATH}" ]]; then
                    if grep -q '"hooks"' "${FILE_PATH}" 2>/dev/null || grep -q '"PostToolUse"' "${FILE_PATH}" 2>/dev/null; then
                        if ! is_unlocked "hooks_user"; then
                            unlock_achievement "hooks_user"
                        fi
                    fi
                fi
            fi

            # mcp_connector (.mcp.json)
            if [[ "${FILE_PATH}" =~ \.mcp\.json$ ]]; then
                if ! is_unlocked "mcp_connector"; then
                    unlock_achievement "mcp_connector"
                fi
            fi

            # skill_creator (.claude/skills/*.md)
            if [[ "${FILE_PATH}" =~ \.claude/skills/.*\.md$ ]]; then
                if ! is_unlocked "skill_creator"; then
                    unlock_achievement "skill_creator"
                fi
            fi

            # command_crafter (.claude/commands/*.md)
            if [[ "${FILE_PATH}" =~ \.claude/commands/.*\.md$ ]]; then
                if ! is_unlocked "command_crafter"; then
                    unlock_achievement "command_crafter"
                fi
            fi

            # agent_architect (.claude/agents/*.md)
            if [[ "${FILE_PATH}" =~ \.claude/agents/.*\.md$ ]]; then
                if ! is_unlocked "agent_architect"; then
                    unlock_achievement "agent_architect"
                fi
            fi

            # cicd_pioneer (.github/workflows/*.yml)
            if [[ "${FILE_PATH}" =~ \.github/workflows/.*\.ya?ml$ ]]; then
                if ! is_unlocked "cicd_pioneer"; then
                    unlock_achievement "cicd_pioneer"
                fi
            fi
            ;;

        Edit)
            # first_edit
            if ! is_unlocked "first_edit"; then
                unlock_achievement "first_edit"
            fi
            ;;

        Read)
            # visual_inspector (image files) - case insensitive
            FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty')
            FILE_PATH_LOWER="${FILE_PATH,,}"
            if [[ "${FILE_PATH_LOWER}" =~ \.(png|jpg|jpeg|gif|webp|svg|bmp|ico)$ ]]; then
                if ! is_unlocked "visual_inspector"; then
                    unlock_achievement "visual_inspector"
                fi
            fi
            ;;

        Glob|Grep)
            # code_detective
            if ! is_unlocked "code_detective"; then
                unlock_achievement "code_detective"
            fi
            ;;

        WebFetch)
            # doc_hunter
            if ! is_unlocked "doc_hunter"; then
                unlock_achievement "doc_hunter"
            fi
            ;;

        TodoWrite)
            # task_planner
            if ! is_unlocked "task_planner"; then
                unlock_achievement "task_planner"
            fi
            ;;

        AskUserQuestion)
            # communicator
            if ! is_unlocked "communicator"; then
                unlock_achievement "communicator"
            fi
            ;;

        Bash)
            COMMAND=$(echo "$TOOL_INPUT" | jq -r '.command // empty')

            # git_commit (git add/commit)
            if [[ "${COMMAND}" =~ git[[:space:]]+(add|commit) ]]; then
                if ! is_unlocked "git_commit"; then
                    unlock_achievement "git_commit"
                fi
            fi

            # git_push
            if [[ "${COMMAND}" =~ git[[:space:]]+push ]]; then
                if ! is_unlocked "git_push"; then
                    unlock_achievement "git_push"
                fi
            fi

            # run_tests (includes "npm run test" and direct test commands)
            if [[ "${COMMAND}" =~ (npm|yarn|pnpm)[[:space:]]+(run[[:space:]]+)?(test|vitest|jest) ]] || \
               [[ "${COMMAND}" =~ pytest ]] || \
               [[ "${COMMAND}" =~ go[[:space:]]+test ]] || \
               [[ "${COMMAND}" =~ cargo[[:space:]]+test ]] || \
               [[ "${COMMAND}" =~ bun[[:space:]]+test ]]; then
                if ! is_unlocked "run_tests"; then
                    unlock_achievement "run_tests"
                fi
            fi
            ;;

        Task)
            if ! is_unlocked "multi_agent"; then
                unlock_achievement "multi_agent"
            fi
            ;;

        Skill)
            if ! is_unlocked "skill_invoker"; then
                unlock_achievement "skill_invoker"
            fi

            # ralph_starter
            SKILL_NAME=$(echo "$TOOL_INPUT" | jq -r '.skill // empty')
            if [[ "${SKILL_NAME}" =~ ralph-loop|ralph ]]; then
                if ! is_unlocked "ralph_starter"; then
                    unlock_achievement "ralph_starter"
                fi
            fi
            ;;

        WebSearch)
            if ! is_unlocked "web_searcher"; then
                unlock_achievement "web_searcher"
            fi
            ;;

        mcp__*)
            # Any MCP tool
            if ! is_unlocked "first_mcp"; then
                unlock_achievement "first_mcp"
            fi
            ;;
    esac
}

# Main
init_state
read_input
check_achievements

exit 0
