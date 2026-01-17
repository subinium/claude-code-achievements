# Changelog

All notable changes to this project will be documented in this file.

## [1.2.2] - 2026-01-17

### Removed
- **Skill Master** (skill_invoker) achievement - detection was unreliable (now 26 achievements)

### Fixed
- Race condition in unlock_achievement with flock file locking
- `/achievements` command now uses dynamic counting instead of hardcoded numbers
- Category headers showing incorrect unlocked counts

## [1.2.1] - 2026-01-17

### Fixed
- Updated CHANGELOG with correct 1.2.0 changes

## [1.2.0] - 2026-01-17

### Added
- 🧩 **Plugin Explorer** achievement - Install a plugin from the marketplace using `/plugin`
- Trigger messages in notifications showing what action unlocked each achievement
- Full i18n support for notification text (EN, KO, ZH, ES, JA)

### Changed
- Compact terminal notifications (no more collapsed output)
- `/achievements` command now shows tips for unlocked achievements
- Plugin installation detected via Stop hook (checks settings.json for `@claude-plugins-official`)

### Note
- Version jump to 1.2.0 due to npm version management (1.1.1-1.1.5 were previously unpublished and cannot be reused)

## [1.1.5] - 2025-01-17

### Added
- CONTRIBUTING.md - contribution guidelines
- CODE_OF_CONDUCT.md - community standards
- SECURITY.md - security policy
- GitHub issue/PR templates (bug report, feature request, new achievement)
- Plugin structure documentation in all README translations

### Fixed
- Case-insensitive image extension detection for visual_inspector achievement
- Added `npm run test` pattern for quality_guardian achievement

### Changed
- All README translations now include Architecture subsections

## [1.1.4] - 2025-01-17

### Added
- README translations: Chinese (zh), Spanish (es), Japanese (ja)
- Logo icon in all README headers
- Custom notification icon support for Linux (notify-send)
- 5 language options in installer (en, zh, es, ko, ja)

### Changed
- All READMEs now link to all 5 language versions

## [1.1.3] - 2025-01-17

### Changed
- Localized notification subtitle (e.g., "5/26 달성" for Korean)

## [1.1.2] - 2025-01-17

### Added
- Chinese (zh), Spanish (es), Japanese (ja) language support

### Changed
- Show description for unlocked achievements in `/achievements` command
- Removed leftover `rarity` keys from i18n files

## [1.1.1] - 2025-01-17

### Changed
- Removed "Data Scientist" (notebook_editor) achievement
- Improved "Communicator" description in README
- Made achievement tables collapsible in README
- Fixed achievement count: 26 total

## [1.1.0] - 2025-01-17

### Added - 12 New Achievements (15 → 26 total)

### Changed - Simplified UI
- **Removed rarity system** - No more COMMON/RARE/EPIC labels
- **New view options:**
  - `/achievements` - Show unlocked only (default, compact)
  - `/achievements locked` - Show locked with hints
  - `/achievements all` - Show all by category
- Cleaner notification design

**Basics**
- 🔍 **Code Detective** - Use Glob or Grep to search codebase

**Workflow**
- 📋 **Task Planner** - Use TodoWrite for task tracking
- 🗣️ **Communicator** - Claude asks clarifying questions via AskUserQuestion
- 🌍 **Global Curator** - Set up global `~/.claude/CLAUDE.md`
- 🚦 **CI/CD Pioneer** - Create GitHub Actions workflow

**Power Tools**
- 🎨 **Visual Inspector** - Analyze images or screenshots
- 📡 **Doc Hunter** - Fetch and analyze web pages with WebFetch
- 📜 **Skill Creator** - Create custom skills in `.claude/skills/`
- ⌨️ **Command Crafter** - Create custom slash commands

**Mastery**
- 🔗 **MCP Connector** - Configure `.mcp.json` for external integrations
- 🤖 **Agent Architect** - Create custom agents in `.claude/agents/`
- 🛡️ **Security Guard** - Configure security permissions

### Changed
- Improved notification UI with description showing unlock reason
- Better ANSI color support for terminal display
- Enhanced README with architecture documentation

## [1.0.2] - 2025-01-17

### Changed
- Show unlock reason (description) in notifications
- macOS notifications now play Glass sound
- Better notification layout

## [1.0.1] - 2025-01-17

### Changed
- Replaced emoji-based rarity indicators with ANSI colored text
- Added colored progress bar with gradient
- Improved terminal notification styling
- Better visual hierarchy with bold/dim text
- Cleaner box drawing characters

## [1.0.0] - 2025-01-17

### Added
- Initial release
- 15 achievements across 4 categories
- Real-time tracking via PostToolUse hooks
- System notifications (macOS/Linux/Windows)
- Terminal fallback notifications
- Multi-language support (English/Korean)
- `/achievements` and `/achievements-settings` commands
