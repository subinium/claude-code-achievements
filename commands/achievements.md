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

### Step 2: Format Output

**IMPORTANT: Output directly in your response text, NOT via bash. Bash output gets collapsed.**

#### Default View (unlocked)
```
🎮 **Claude Code Achievements** — 4/28 unlocked (14%)
▰▰▰▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱

✓ Unlocked

✏️ **First Touch** — Edit a file with Claude's help
   💡 Be specific: instead of 'fix the bug', say 'fix the TypeError in login.js line 42'

📝 **Creator** — Create a new file
   💡 Claude can create entire files from description. Try: 'Create a React component for a login form'

🔍 **Code Detective** — Search codebase with Glob or Grep
   💡 Glob finds files by pattern, Grep searches content. Faster than manual searching!

🤖 **Delegation Master** — Use Task tool to spawn sub-agents
   💡 Task tool creates specialized agents for complex work. Great for parallel exploration.
```

#### Locked View (/achievements locked)
```
🎮 **Claude Code Achievements** — 4/28 unlocked (14%)
▰▰▰▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱

○ Locked
  📋 Project Curator — Create CLAUDE.md for project context
  🎯 Strategic Thinker — Use Plan mode for complex tasks
  📦 Version Controller — Commit changes with Claude
  ...
```

#### All View (/achievements all)
```
🎮 **Claude Code Achievements** — 4/28 unlocked (14%)

**Getting Started**
  ✓ ✏️ First Touch — Edit a file with Claude's help
  ✓ 📝 Creator — Create a new file
  ○ 📋 Project Curator — Create CLAUDE.md

**Workflow**
  ○ 🎯 Strategic Thinker — Use Plan mode
  ...
```

Rules:
- ✓ = unlocked: icon + **name** (bold) + description + 💡 tip
- ○ = locked: icon + name + description only
- Tips should be informative but concise (1-2 sentences max)
- Group by category when showing all
- Use proper spacing for readability

### Step 3: Suggest Next

For unlocked/locked views, suggest ONE easy achievement to unlock next with a brief actionable hint.

## Hint Mode (/achievements hint)

Show tips for 2-3 locked achievements. Read the `tip` field from achievements.json:

```
💡 **Tips to unlock more:**

📋 **Project Curator**
Create a CLAUDE.md file for your project
→ Include tech stack, coding style, and common commands

🎯 **Strategic Thinker**
Use Plan mode for your next complex task
→ Press Shift+Tab twice to enter Plan mode
```
