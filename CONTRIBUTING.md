# Contributing to Claude Code Achievements

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## Ways to Contribute

### 1. Add New Achievements

To add a new achievement:

1. **Define the achievement** in `data/achievements.json`:
```json
{
  "your_achievement_id": {
    "name": "Achievement Name",
    "description": "What triggers this achievement",
    "category": "basics|workflow|tools|mastery",
    "icon": "emoji",
    "tip": "Helpful tip for users"
  }
}
```

2. **Add translations** to all i18n files in `data/i18n/`:
   - `en.json` (English - required)
   - `ko.json` (Korean)
   - `zh.json` (Chinese)
   - `es.json` (Spanish)
   - `ja.json` (Japanese)

3. **Add detection logic** in `hooks/track-achievement.sh`:
```bash
ToolName)
    if ! is_unlocked "your_achievement_id"; then
        unlock_achievement "your_achievement_id"
    fi
    ;;
```

4. **Update README** achievement tables in all language versions.

5. **Update CHANGELOG.md** with your addition.

### 2. Add New Language

To add a new language translation:

1. Create `data/i18n/{lang_code}.json` based on `en.json`
2. Translate all strings (achievements, categories, UI)
3. Add the language option to `bin/install.js`
4. Create `README.{lang_code}.md`
5. Update all README files to link to the new language

### 3. Report Bugs

Open an issue with:
- Clear description of the bug
- Steps to reproduce
- Expected vs actual behavior
- OS and Claude Code version

### 4. Suggest Features

Open an issue with:
- Description of the feature
- Use case / why it's useful
- Proposed implementation (optional)

## Development Setup

```bash
# Clone the repository
git clone https://github.com/subinium/claude-code-achievements.git
cd claude-code-achievements

# Install locally for testing
node bin/install.js

# Test notification
~/.claude/plugins/local/claude-code-achievements/scripts/show-notification.sh first_edit
```

## Code Style

- Use 4-space indentation in shell scripts
- Use descriptive variable names
- Add comments for complex logic
- Follow existing patterns in the codebase

## Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test locally
5. Update documentation if needed
6. Commit with clear messages
7. Push and create a Pull Request

## Commit Message Format

```
type: short description

- Detailed change 1
- Detailed change 2
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## Questions?

Feel free to open an issue or discussion!
