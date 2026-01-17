---
description: "Configure your achievements settings"
---

# /achievements-settings Command

## Instructions

Use AskUserQuestion to let the user configure settings interactively.

### Step 1: Read Current Settings

```bash
cat ~/.claude/achievements/state.json | jq '.settings'
```

### Step 2: Show Menu

Use AskUserQuestion with ALL settings in one question (multiSelect: false):

```
Question: "Select a setting to change"
Header: "Settings"
Options:
- "Language: {current}" (description: "Change display language")
- "Notifications: {on/off}" (description: "Toggle unlock notifications")
- "Style: {current}" (description: "terminal / system / both")
- "Reset Progress" (description: "Clear all achievements")
```

### Step 3: Based on Selection

**If "Language"**: Ask with options "English", "한국어", then apply:
```bash
jq '.settings.language = "en"' ~/.claude/achievements/state.json > tmp.json && mv tmp.json ~/.claude/achievements/state.json
```

**If "Notifications"**: Ask "On" or "Off", then apply:
```bash
jq '.settings.notifications = true' ~/.claude/achievements/state.json > tmp.json && mv tmp.json ~/.claude/achievements/state.json
```

**If "Style"**: Ask "terminal", "system", "both", then apply:
```bash
jq '.settings.notification_style = "system"' ~/.claude/achievements/state.json > tmp.json && mv tmp.json ~/.claude/achievements/state.json
```

**If "Reset"**: Confirm first, then:
```bash
jq '.achievements = {} | .counters = {"ralph_iterations": 0, "files_read": 0, "edits_made": 0} | .session = {"files_read_set": []}' ~/.claude/achievements/state.json > tmp.json && mv tmp.json ~/.claude/achievements/state.json
```

### Step 4: Confirm

Tell user what changed: "✓ Language changed to English"

## Direct Arguments

Skip menu if arguments provided:
- `/achievements-settings language en`
- `/achievements-settings notifications off`
- `/achievements-settings notification-style system`
- `/achievements-settings reset`
