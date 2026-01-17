<div align="center">

<img src="assets/icon.png" alt="Claude Code Achievements" width="120" height="120">

# Claude Code Achievements

**Steam-style achievement system for Claude Code**

[![npm version](https://img.shields.io/npm/v/claude-code-achievements.svg?style=flat-square&color=CB3837)](https://www.npmjs.com/package/claude-code-achievements)
[![license](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](LICENSE)
[![node](https://img.shields.io/badge/node-%3E%3D14.0.0-brightgreen.svg?style=flat-square)](package.json)

Gamify your coding journey and unlock achievements as you master Claude Code features!

[Installation](#installation) · [Usage](#usage) · [Achievements](#achievements) · [How It Works](#architecture)

**[中文](README.zh.md)** · **[Español](README.es.md)** · **[한국어](README.ko.md)** · **[日本語](README.ja.md)**

</div>

---

## Features

- **26 Achievements** across 4 categories
- **Real-time notifications** via system alerts or terminal
- **Multi-language support** (EN / 中文 / ES / 한국어 / 日本語)
- **Cross-platform** (macOS / Linux / Windows)
- **Global installation** - works across all your projects

## Installation

```bash
npx claude-code-achievements
```

The interactive installer will:
1. Auto-detect your OS and notification capability
2. Ask for language preference (English/한국어)
3. Configure notification style (system/terminal/both)
4. Install globally to `~/.claude/plugins/local/`

> **Note:** This plugin installs **globally** and works across all your projects automatically.

### Manual Installation

```bash
git clone https://github.com/subinium/claude-code-achievements.git
cd claude-code-achievements
node bin/install.js
```

## Usage

| Command | Description |
|---------|-------------|
| `/achievements` | View unlocked achievements (default) |
| `/achievements locked` | View locked achievements with hints |
| `/achievements all` | View all achievements by category |
| `/achievements-settings` | Change language or notification settings |

### Category Filters

```bash
/achievements basics    # Getting Started
/achievements workflow  # Workflow
/achievements tools     # Power Tools
/achievements mastery   # Mastery
```

## Achievements

<details>
<summary><b>Getting Started</b> (4 achievements)</summary>

| Achievement | How to Unlock |
|-------------|---------------|
| ✏️ **First Touch** | Edit any file |
| 📝 **Creator** | Create a new file |
| 🔍 **Code Detective** | Use Glob or Grep to search codebase |
| 📋 **Project Curator** | Create `CLAUDE.md` for project context |

</details>

<details>
<summary><b>Workflow</b> (8 achievements)</summary>

| Achievement | How to Unlock |
|-------------|---------------|
| 📋 **Task Planner** | Use TodoWrite for task tracking |
| 🎯 **Strategic Thinker** | Use Plan mode (`Shift+Tab` twice) |
| 🗣️ **Communicator** | Claude uses `AskUserQuestion` to clarify requirements or present options |
| 🌍 **Global Curator** | Set up `~/.claude/CLAUDE.md` |
| 📦 **Version Controller** | Commit with Claude |
| 🚀 **Ship It!** | Push to remote repository |
| 🧪 **Quality Guardian** | Run tests with Claude |
| 🚦 **CI/CD Pioneer** | Create GitHub Actions workflow |

</details>

<details>
<summary><b>Power Tools</b> (9 achievements)</summary>

| Achievement | How to Unlock |
|-------------|---------------|
| 🎨 **Visual Inspector** | Analyze image or screenshot |
| 📡 **Doc Hunter** | Fetch and analyze a web page |
| 🤖 **Delegation Master** | Use `Task` tool for sub-agents |
| 🔌 **MCP Pioneer** | Use any MCP tool |
| 🌐 **Web Explorer** | Use `WebSearch` tool |
| ⚙️ **Customizer** | Modify Claude Code settings |
| 📜 **Skill Creator** | Create custom skill in `.claude/skills/` |
| ⌨️ **Command Crafter** | Create custom slash command |
| 🧩 **Plugin Explorer** | Install a plugin from marketplace |

</details>

<details>
<summary><b>Mastery</b> (5 achievements)</summary>

| Achievement | How to Unlock |
|-------------|---------------|
| 🪝 **Automation Architect** | Set up Claude Code hooks |
| 🔗 **MCP Connector** | Configure `.mcp.json` for integrations |
| 🤖 **Agent Architect** | Create custom agent in `.claude/agents/` |
| 🛡️ **Security Guard** | Configure security permissions |
| 🔄 **Loop Master** | Start autonomous coding loop |

</details>

---

## Architecture

This plugin uses **Claude Code's hook system** to track your actions in real-time.

```
┌─────────────────────────────────────────────────────────────┐
│                     CLAUDE CODE SESSION                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   You: "Edit the config file"                               │
│                     │                                        │
│                     ▼                                        │
│   ┌─────────────────────────────────────┐                   │
│   │         Claude uses Edit tool        │                   │
│   └─────────────────────────────────────┘                   │
│                     │                                        │
│                     ▼                                        │
│   ┌─────────────────────────────────────┐                   │
│   │    PostToolUse Hook Triggered        │◄── hooks.json    │
│   │    → track-achievement.sh            │                   │
│   └─────────────────────────────────────┘                   │
│                     │                                        │
│         ┌──────────┴──────────┐                             │
│         ▼                     ▼                             │
│   ┌───────────┐        ┌───────────┐                        │
│   │  Match!   │        │ No Match  │                        │
│   │           │        │           │                        │
│   │ Unlock    │        │ Continue  │                        │
│   │ Notify    │        └───────────┘                        │
│   │ Save      │                                              │
│   └───────────┘                                              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Plugin Structure

```
~/.claude/plugins/local/claude-code-achievements/
├── .claude-plugin/
│   └── plugin.json          # Plugin metadata
├── hooks/
│   ├── hooks.json           # Hook definitions (PostToolUse, Stop)
│   ├── track-achievement.sh # Main tracking logic
│   └── track-stop.sh        # Session end handler
├── commands/
│   ├── achievements.md      # /achievements command
│   └── achievements-settings.md
├── scripts/
│   ├── show-achievements.sh # Display UI
│   └── show-notification.sh # Notification handler
└── data/
    ├── achievements.json    # Achievement definitions
    └── i18n/
        ├── en.json          # English
        ├── zh.json          # 中文
        ├── es.json          # Español
        ├── ko.json          # 한국어
        └── ja.json          # 日本語
```

### How Hooks Work

The plugin registers two hooks in Claude Code:

| Hook | Trigger | Purpose |
|------|---------|---------|
| `PostToolUse` | After any tool execution | Check if action unlocks achievement |
| `Stop` | Session ends | Save session stats |

### How Commands Work

Slash commands (`/achievements`) are implemented as **markdown files** in `~/.claude/commands/`. Claude Code reads these and executes the embedded instructions.

---

## Notifications

System notifications are auto-detected during installation:

| OS | Method | Sound |
|----|--------|-------|
| macOS | `osascript` | Glass |
| Linux | `notify-send` | System default |
| Windows | PowerShell | System default |
| Fallback | Terminal | None |

### Install notify-send on Linux

```bash
# Ubuntu/Debian
sudo apt install libnotify-bin

# Fedora
sudo dnf install libnotify

# Arch
sudo pacman -S libnotify
```

---

## Configuration

Settings are stored in `~/.claude/achievements/state.json`:

```json
{
  "settings": {
    "language": "en",
    "notifications": true,
    "notification_style": "system"
  },
  "achievements": {},
  "counters": {}
}
```

| Setting | Values | Description |
|---------|--------|-------------|
| `language` | `"en"`, `"zh"`, `"es"`, `"ko"`, `"ja"` | UI language |
| `notifications` | `true`, `false` | Enable/disable alerts |
| `notification_style` | `"system"`, `"terminal"`, `"both"` | Alert method |

---

## Troubleshooting

<details>
<summary><b>Achievements not unlocking?</b></summary>

```bash
# Check plugin is installed
ls ~/.claude/plugins/local/claude-code-achievements/

# Check state file exists
cat ~/.claude/achievements/state.json

# Verify hooks are loaded (restart Claude Code after install)
```

</details>

<details>
<summary><b>Reset all progress</b></summary>

```bash
rm ~/.claude/achievements/state.json
```

</details>

<details>
<summary><b>Reinstall plugin</b></summary>

```bash
npx claude-code-achievements@latest
```

</details>

---

## Contributing

Contributions welcome! Ideas:

- New achievements
- New language translations
- UI improvements
- Bug fixes

## License

MIT © [subinium](https://github.com/subinium)

---

<div align="center">

**Happy coding!**

</div>
