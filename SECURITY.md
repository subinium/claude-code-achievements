# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.2.x   | :white_check_mark: |
| 1.1.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability, please report it responsibly:

1. **DO NOT** open a public issue
2. Email the maintainer directly or use GitHub's private vulnerability reporting
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

## Response Timeline

- **Initial Response**: Within 48 hours
- **Status Update**: Within 7 days
- **Fix Release**: Depends on severity

## Security Considerations

This plugin:
- Stores achievement data locally in `~/.claude/achievements/`
- Does not transmit any data externally
- Does not require elevated privileges
- Uses shell scripts executed via Claude Code hooks
- Modifies `~/.claude/settings.json` to register hooks (v1.2.0+)

## What the Installer Modifies

| File | Changes |
|------|---------|
| `~/.claude/plugins/local/claude-code-achievements/` | Plugin files |
| `~/.claude/commands/` | Symlinks to plugin commands |
| `~/.claude/settings.json` | Adds hooks and enabledPlugins entry |
| `~/.claude/achievements/state.json` | Achievement progress data |

## Best Practices

- Keep your Claude Code and this plugin updated
- Review hook scripts if you have concerns
- Report any suspicious behavior immediately
- Restart Claude Code after installation for hooks to take effect
