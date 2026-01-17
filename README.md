# 🎮 Claude Code Achievements

Steam-style achievement system for [Claude Code](https://claude.ai/claude-code). Gamify your coding journey and unlock achievements as you master Claude Code features!

## Installation

```bash
npx claude-code-achievements
```

The interactive installer will:
1. **Auto-detect** your OS (macOS/Linux/Windows)
2. **Auto-detect** system notification capability
3. Ask for language preference (English/한국어)
4. Configure notification style (system/terminal/both)
5. Install to `~/.claude/plugins/local/claude-code-achievements`

### Manual Installation

```bash
git clone https://github.com/subinium/claude-code-achievements.git
cd claude-code-achievements
node bin/install.js
```

## Usage

| Command | Description |
|---------|-------------|
| `/achievements` | View all achievements with progress |
| `/achievements hint` | Get tips for unlocking achievements |
| `/achievements basics` | View "Getting Started" category |
| `/achievements workflow` | View "Workflow" category |
| `/achievements tools` | View "Power Tools" category |
| `/achievements mastery` | View "Mastery" category |
| `/achievements-settings` | Change language or notification settings |

## Achievements (15 total)

### Getting Started (⬜ Common / 🟩 Uncommon)

| # | Achievement | Description | How to Unlock |
|---|-------------|-------------|---------------|
| 1 | ✏️ **First Touch** ⬜ | Edit a file | Use `Edit` tool |
| 2 | 📝 **Creator** ⬜ | Create a new file | Use `Write` tool |
| 3 | 📋 **Project Curator** 🟩 | Create CLAUDE.md | Write to `CLAUDE.md` |

### Workflow (🟩 Uncommon)

| # | Achievement | Description | How to Unlock |
|---|-------------|-------------|---------------|
| 4 | 🎯 **Strategic Thinker** | Use Plan mode | Press `Shift+Tab` twice |
| 5 | 📦 **Version Controller** | Commit with Claude | Run `git add` or `git commit` |
| 6 | 🚀 **Ship It!** | Push to remote | Run `git push` |
| 7 | 🧪 **Quality Guardian** | Run tests | Run `npm test`, `pytest`, etc. |

### Power Tools (🟦 Rare)

| # | Achievement | Description | How to Unlock |
|---|-------------|-------------|---------------|
| 8 | 🤖 **Delegation Master** | Use sub-agents | Use `Task` tool |
| 9 | 🔌 **MCP Pioneer** | Use MCP tool | Use any `mcp__*` tool |
| 10 | 🌐 **Web Explorer** | Search the web | Use `WebSearch` tool |
| 11 | ⚡ **Skill Master** | Use slash command | Use `Skill` tool (e.g., `/commit`) |
| 12 | 📓 **Data Scientist** | Edit notebook | Use `NotebookEdit` tool |
| 13 | ⚙️ **Customizer** | Modify settings | Write to `.claude/settings*.json` |

### Mastery (🟪 Epic / 🟨 Legendary)

| # | Achievement | Description | How to Unlock |
|---|-------------|-------------|---------------|
| 14 | 🪝 **Automation Architect** 🟪 | Set up hooks | Write file with `"hooks"` config |
| 15 | 🔄 **Loop Master** 🟨 | Start Ralph Loop | Use `/ralph-loop` skill |

## Rarity System

| Rarity | Color | Count | Difficulty |
|--------|-------|-------|------------|
| Common | ⬜ | 2 | First session |
| Uncommon | 🟩 | 5 | Regular usage |
| Rare | 🟦 | 6 | Power user features |
| Epic | 🟪 | 1 | Advanced automation |
| Legendary | 🟨 | 1 | Expert level |

## Notifications

System notifications are **auto-detected** during installation:

| OS | Method | Requirement | Auto-detected |
|----|--------|-------------|---------------|
| macOS | `osascript` | Built-in | ✅ Always |
| Linux | `notify-send` | `libnotify-bin` | ✅ Checked |
| Windows | PowerShell | Windows 10+ | ✅ Checked |
| Fallback | Terminal | None | ✅ Always |

**Note:** If system notifications aren't available, terminal notifications are used automatically.

### Install `notify-send` on Linux

```bash
# Ubuntu/Debian
sudo apt install libnotify-bin

# Fedora
sudo dnf install libnotify

# Arch
sudo pacman -S libnotify
```

## How It Works

```
┌─────────────────────────────────────────────────────────┐
│  You use a tool (Edit, Write, Bash, Task, etc.)        │
│                         │                               │
│                         ▼                               │
│  ┌─────────────────────────────────────────────────┐   │
│  │ PostToolUse Hook → track-achievement.sh         │   │
│  │ Checks tool_name, tool_input, permission_mode   │   │
│  └─────────────────────────────────────────────────┘   │
│                         │                               │
│          ┌──────────────┴──────────────┐               │
│          ▼                             ▼               │
│  ┌───────────────┐           ┌─────────────────┐       │
│  │ Match found!  │           │ No match        │       │
│  │ → Unlock      │           │ → Continue      │       │
│  │ → Notify      │           └─────────────────┘       │
│  │ → Save state  │                                     │
│  └───────────────┘                                     │
└─────────────────────────────────────────────────────────┘
```

## Files

| Path | Description |
|------|-------------|
| `~/.claude/achievements/state.json` | Your progress & settings |
| `~/.claude/plugins/local/claude-code-achievements/` | Plugin files |
| `~/.claude/commands/achievements.md` | Slash command |

## Settings

Edit `~/.claude/achievements/state.json`:

```json
{
  "settings": {
    "language": "en",              // "en" | "ko"
    "notifications": true,          // true | false
    "notification_style": "system"  // "system" | "terminal" | "both"
  }
}
```

## Troubleshooting

### Achievements not unlocking?

```bash
# 1. Check hooks are registered
cat ~/.claude/settings.json | grep -A5 "hooks"

# 2. Verify plugin installed
ls ~/.claude/plugins/local/claude-code-achievements/

# 3. Check state file
cat ~/.claude/achievements/state.json
```

### Reset progress

```bash
rm ~/.claude/achievements/state.json
```

### Reinstall

```bash
npx claude-code-achievements
```

## Languages

- 🇺🇸 English
- 🇰🇷 한국어

## Contributing

PRs welcome! Ideas:
- New achievements
- New languages
- Bug fixes

## License

MIT

---

Happy coding! 🎮
