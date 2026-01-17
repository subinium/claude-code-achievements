#!/bin/bash
# init-state.sh - Initialize or reset the achievements state file
# Usage: init-state.sh [--reset]

set -e

STATE_DIR="${HOME}/.claude/achievements"
STATE_FILE="${STATE_DIR}/state.json"

# Check for reset flag
if [[ "$1" == "--reset" ]]; then
    rm -f "${STATE_FILE}"
    echo "State file reset."
fi

# Create directory if needed
mkdir -p "${STATE_DIR}"

# Create initial state if doesn't exist
if [[ ! -f "${STATE_FILE}" ]]; then
    cat > "${STATE_FILE}" << 'EOF'
{
  "settings": {
    "language": "en",
    "notifications": true
  },
  "achievements": {},
  "counters": {
    "ralph_iterations": 0,
    "files_read": 0,
    "edits_made": 0
  },
  "session": {
    "files_read_set": [],
    "ralph_loop_active": false
  }
}
EOF
    echo "State file initialized at: ${STATE_FILE}"
else
    echo "State file already exists at: ${STATE_FILE}"
fi

exit 0
