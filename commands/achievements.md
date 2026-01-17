---
description: "Display your Claude Code achievements progress"
---

# /achievements Command

Display Claude Code achievements progress. Output directly in your response (not bash).

## Arguments

- `(none)` or `all`: Show all achievements
- `hint` or `tips`: Show tips for unlocking
- `<category>`: Show specific category (basics, workflow, tools, mastery)

## Instructions

### Step 1: Read Data

Use the Read tool to read these files:
- `~/.claude/plugins/local/claude-code-achievements/data/achievements.json`
- `~/.claude/achievements/state.json`

### Step 2: Format Output

**IMPORTANT: Output directly in your response text, NOT via bash. Bash output gets collapsed and has bad UX.**

Format like this (compact, readable):

```
🎮 **Claude Code Achievements** — 4/18 unlocked (22%)
████░░░░░░░░░░░░░░░░

**Getting Started**
✅ First Touch ⬜ · ✅ Creator ⬜
⬛ Hello, Claude! ⬜ — Start your first conversation
⬛ Project Curator 🟩 — Create CLAUDE.md for project context

**Workflow**
⬛ Strategic Thinker 🟩 — Use Plan mode for complex tasks
⬛ Version Controller 🟩 — Commit changes with Claude
⬛ Ship It! 🟩 — Push changes to remote
⬛ Quality Guardian 🟩 — Run tests with Claude

**Power Tools**
✅ Delegation Master 🟦
⬛ MCP Pioneer 🟦 — Use an MCP tool
⬛ Web Explorer 🟦 — Search the web
⬛ Skill Master 🟦 — Use a slash command
⬛ Data Scientist 🟦 — Edit a Jupyter notebook
⬛ Customizer 🟦 — Modify Claude Code settings

**Mastery**
⬛ Automation Architect 🟪 — Set up hooks
⬛ Loop Master 🟪 — Start autonomous coding loop
⬛ Parallel Universe 🟪 — Run multiple Claude sessions
⬛ Full Stack Vibecoder 🟨 — Work on frontend, backend, DB in one session

_Rarity: ⬜ Common · 🟩 Uncommon · 🟦 Rare · 🟪 Epic · 🟨 Legendary_
```

Rules:
- ✅ = unlocked (show name + rarity only)
- ⬛ = locked (show name + rarity + description)
- Group unlocked items on same line when possible
- Keep it compact!

### Step 3: Suggest Next

After showing achievements, suggest ONE easy achievement to unlock next.

## Hint Mode (/achievements hint)

Show tips for 2-3 locked achievements. Read the `tip` field from achievements.json:

```
💡 **Tips to unlock more:**

📋 **Project Curator** (🟩 Uncommon)
Create a CLAUDE.md file for your project
→ Include tech stack, coding style, and common commands

🎯 **Strategic Thinker** (🟩 Uncommon)
Use Plan mode for your next complex task
→ Press Shift+Tab twice to enter Plan mode
```

## Rarity Reference

- ⬜ Common — basic actions
- 🟩 Uncommon — workflow essentials
- 🟦 Rare — power user features
- 🟪 Epic — advanced automation
- 🟨 Legendary — master vibecoder
