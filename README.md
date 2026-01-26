<div align="center">

<img src="assets/icon.png" alt="Claude Code Achievements" width="128" height="128">

# Claude Code Achievements

### Level up your AI coding skills

[![npm version](https://img.shields.io/npm/v/claude-code-achievements.svg?style=for-the-badge&color=FFD700)](https://www.npmjs.com/package/claude-code-achievements)
[![downloads](https://img.shields.io/npm/dt/claude-code-achievements.svg?style=for-the-badge&color=4CAF50)](https://www.npmjs.com/package/claude-code-achievements)
[![license](https://img.shields.io/badge/license-MIT-blue.svg?style=for-the-badge)](LICENSE)

```
╔══════════════════════════════════════════════════════════════╗
║  🎮  UNLOCK ACHIEVEMENTS  •  TRACK PROGRESS  •  HAVE FUN  🎮  ║
╚══════════════════════════════════════════════════════════════╝
```

**Transform your Claude Code experience into an RPG adventure!**

[Quick Start](#-quick-start) · [Achievements](#-achievements) · [Commands](#-commands)

**[中文](README.zh.md)** · **[Español](README.es.md)** · **[한국어](README.ko.md)** · **[日本語](README.ja.md)**

</div>

---

## ✨ Why This Exists

Learning Claude Code is a journey. This plugin turns that journey into a **game**.

- 🏆 **29 Achievements** to unlock across 4 skill trees
- 🔔 **Real-time notifications** when you level up
- 📊 **Track your mastery** from beginner to expert
- 🌍 **5 Languages** supported

---

## 🚀 Quick Start

```bash
npx claude-code-achievements
```

That's it. Start coding and watch the achievements roll in!

---

## 🏆 Achievements

<table>
<tr>
<td width="25%" align="center">

### 🌱 Getting Started
**4 Achievements**

*Your first steps*

</td>
<td width="25%" align="center">

### ⚡ Workflow
**10 Achievements**

*Work smarter*

</td>
<td width="25%" align="center">

### 🔧 Power Tools
**10 Achievements**

*Unlock abilities*

</td>
<td width="25%" align="center">

### 👑 Mastery
**5 Achievements**

*Become a legend*

</td>
</tr>
</table>

---

### 🌱 Getting Started

> *Every master was once a beginner*

| | Achievement | Quest |
|:--:|-------------|-------|
| ✏️ | **First Touch** | Edit any file with Claude |
| 📝 | **Creator** | Create a new file |
| 🔍 | **Code Detective** | Search codebase with Glob or Grep |
| 📋 | **Project Curator** | Create your first `CLAUDE.md` |

---

### ⚡ Workflow

> *Efficiency is intelligent laziness*

| | Achievement | Quest |
|:--:|-------------|-------|
| 📋 | **Task Planner** | Use TodoWrite for task tracking |
| 📋 | **Task Master** | Use TaskCreate/TaskUpdate/TaskList |
| 🎯 | **Strategic Thinker** | Enter Plan mode (`Shift+Tab` × 2) |
| 🗣️ | **Communicator** | Have Claude ask you a clarifying question |
| 🌍 | **Global Curator** | Set up global `~/.claude/CLAUDE.md` |
| 📦 | **Version Controller** | Make a commit with Claude |
| 🚀 | **Ship It!** | Push code to remote |
| 🔀 | **PR Champion** | Create a pull request with `gh pr create` |
| 🧪 | **Quality Guardian** | Run tests |
| 🚦 | **CI/CD Pioneer** | Create GitHub Actions workflow |

---

### 🔧 Power Tools

> *With great power comes great productivity*

| | Achievement | Quest |
|:--:|-------------|-------|
| 🎨 | **Visual Inspector** | Analyze an image or screenshot |
| 📡 | **Doc Hunter** | Fetch and analyze a web page |
| 🤖 | **Delegation Master** | Spawn a sub-agent with Task tool |
| ⏳ | **Multitasker** | Run a command in the background |
| 🔌 | **MCP Pioneer** | Use any MCP tool |
| 🌐 | **Web Explorer** | Search the web |
| ⚙️ | **Customizer** | Modify Claude Code settings |
| 📜 | **Skill Creator** | Create custom skill |
| ⌨️ | **Command Crafter** | Create custom slash command |
| 🧩 | **Plugin Explorer** | Install a marketplace plugin |

---

### 👑 Mastery

> *The elite few who push the boundaries*

| | Achievement | Quest |
|:--:|-------------|-------|
| 🪝 | **Automation Architect** | Set up Claude Code hooks |
| 🔗 | **MCP Connector** | Configure `.mcp.json` integration |
| 🤖 | **Agent Architect** | Create a custom agent |
| 🛡️ | **Security Guard** | Configure security permissions |
| 🔄 | **Loop Master** | Start autonomous coding loop |

---

## 🎮 Commands

```bash
/achievements          # View your unlocked achievements
/achievements locked   # See what's left to unlock (with hints!)
/achievements all      # Full achievement list by category
/achievements-settings # Configure language & notifications
```

### Category Filters

```bash
/achievements basics    # 🌱 Getting Started
/achievements workflow  # ⚡ Workflow
/achievements tools     # 🔧 Power Tools
/achievements mastery   # 👑 Mastery
```

---

## 🔔 Notifications

Achievement unlocked? You'll know instantly!

| Platform | Style |
|----------|-------|
| 🍎 macOS | Native notification with sound |
| 🐧 Linux | System notification |
| 🪟 Windows | Toast notification |
| 💻 Fallback | Terminal alert |

---

## 🛠️ How It Works

```
   You: "Edit the config file"
              │
              ▼
   ┌─────────────────────┐
   │  Claude uses Edit   │
   └─────────────────────┘
              │
              ▼
   ┌─────────────────────┐
   │  🎯 Hook triggered  │──▶ Achievement check
   └─────────────────────┘
              │
       ┌──────┴──────┐
       ▼             ▼
   ┌───────┐    ┌────────┐
   │ 🏆 +1 │    │  None  │
   │Unlock!│    │Continue│
   └───────┘    └────────┘
```

The plugin hooks into Claude Code's event system. Every tool use is tracked. When you hit a milestone, you get rewarded!

---

## 🌍 Languages

- 🇺🇸 English
- 🇨🇳 中文
- 🇪🇸 Español
- 🇰🇷 한국어
- 🇯🇵 日本語

Change anytime with `/achievements-settings`

---

## 📂 Your Progress

All progress is saved locally:

```
~/.claude/achievements/state.json
```

Reset your journey anytime:
```bash
rm ~/.claude/achievements/state.json
```

---

## 🤝 Contributing

Got an idea for a new achievement? Found a bug? Contributions welcome!

- 🏆 Suggest new achievements
- 🌍 Add translations
- 🐛 Report issues
- ⭐ Star this repo!

---

<div align="center">

### Ready to start your journey?

```bash
npx claude-code-achievements
```

**Level up. Unlock achievements. Have fun coding!**

---

MIT © [subinium](https://github.com/subinium)

</div>
