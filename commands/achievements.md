---
description: "Display your Claude Code achievements progress"
---

# /achievements Command

Display Claude Code achievements progress. Output directly in your response (not bash).

## Arguments

- `(none)` or `unlocked`: Show unlocked achievements only (default)
- `locked`: Show locked achievements with hints
- `all`: Show all achievements by category
- `<category>`: Show specific category (basics, workflow, tools, mastery)

## Instructions

### Step 1: Read Data

Use the Read tool to read these files:
- `~/.claude/achievements/state.json` (check settings.language for user's language preference)
- `~/.claude/plugins/local/claude-code-achievements/data/achievements.json` (default data with icons, categories)
- `~/.claude/plugins/local/claude-code-achievements/data/i18n/{language}.json` (localized name, description, tip)

### Step 2: Count Achievements

**IMPORTANT: Calculate these counts from the JSON files, do NOT use hardcoded numbers!**

1. **Total count**: Count all keys in `achievements.json` → `achievements` object
2. **Unlocked count**: Count achievements in `state.json` → `achievements` object where `unlocked: true`
3. **Per category**: Count achievements by their `category` field

### Step 3: Format Output

**IMPORTANT: Output directly in your response text, NOT via bash. Bash output gets collapsed.**

#### Default View (unlocked)
```
🎮 **Claude Code Achievements** — {unlocked}/{total} unlocked ({percentage}%)
▰▰▰▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱

✓ Unlocked

✏️ **First Touch** — Edit a file with Claude's help
   💡 Be specific: instead of 'fix the bug', say 'fix the TypeError in login.js line 42'

📝 **Creator** — Create a new file
   💡 Claude can create entire files from description.
```

#### Locked View (/achievements locked)
```
🎮 **Claude Code Achievements** — {unlocked}/{total} unlocked ({percentage}%)
▰▰▰▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱

○ Locked
  📋 Project Curator — Create CLAUDE.md for project context
  🎯 Strategic Thinker — Use Plan mode for complex tasks
  ...
```

#### All View (/achievements all)
Show each category with unlocked/total count:

```
🎮 **Claude Code Achievements** — {unlocked}/{total} unlocked ({percentage}%)

**Getting Started** ({category_unlocked}/{category_total})
  ✓ ✏️ **First Touch** — Edit a file with Claude's help
  ✓ 📝 **Creator** — Create a new file
  ○ 📋 Project Curator — Create CLAUDE.md

**Workflow** ({category_unlocked}/{category_total})
  ✓ 🎯 **Strategic Thinker** — Use Plan mode
  ○ 📦 Version Controller — Commit changes with Claude
  ...
```

### Formatting Rules

- ✓ = unlocked: icon + **name** (bold) + description + 💡 tip
- ○ = locked: icon + name (not bold) + description only
- Category header: `**Category Name** (unlocked/total)` - count ONLY that category's achievements
- Progress bar: 20 blocks, filled proportionally to percentage
- Tips should be informative but concise (1-2 sentences max)

### Step 4: Suggest Next

For unlocked/locked views, suggest ONE easy achievement to unlock next with a brief actionable hint.

## Hint Mode (/achievements hint)

Show tips for 2-3 locked achievements:

```
💡 **Tips to unlock more:**

📋 **Project Curator**
Create a CLAUDE.md file for your project
→ Include tech stack, coding style, and common commands

🎯 **Strategic Thinker**
Use Plan mode for your next complex task
→ Press Shift+Tab twice to enter Plan mode
```
