#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const os = require('os');
const readline = require('readline');
const { execSync } = require('child_process');

const PLUGIN_NAME = 'claude-code-achievements';
const TARGET_DIR = path.join(os.homedir(), '.claude', 'plugins', 'local', PLUGIN_NAME);

const ITEMS_TO_COPY = ['.claude-plugin', 'commands', 'hooks', 'scripts', 'data', 'bin', 'assets'];

// ANSI colors
const GREEN = '\x1b[32m';
const CYAN = '\x1b[36m';
const YELLOW = '\x1b[33m';
const MAGENTA = '\x1b[35m';
const DIM = '\x1b[2m';
const BOLD = '\x1b[1m';
const RESET = '\x1b[0m';

function copyRecursive(src, dest) {
  const stat = fs.statSync(src);
  if (stat.isDirectory()) {
    if (!fs.existsSync(dest)) fs.mkdirSync(dest, { recursive: true });
    for (const entry of fs.readdirSync(src)) {
      copyRecursive(path.join(src, entry), path.join(dest, entry));
    }
  } else {
    fs.copyFileSync(src, dest);
    if (src.endsWith('.sh') || src.endsWith('.js')) {
      fs.chmodSync(dest, 0o755);
    }
  }
}

function detectOS() {
  const platform = os.platform();
  if (platform === 'darwin') return 'macOS';
  if (platform === 'win32') return 'Windows';
  return 'Linux';
}

function detectLanguage() {
  const locale = (process.env.LANG || process.env.LC_ALL || process.env.LANGUAGE || '').toLowerCase();
  if (locale.includes('ko')) return 'ko';
  if (locale.includes('zh')) return 'zh';
  if (locale.includes('es')) return 'es';
  if (locale.includes('ja')) return 'ja';
  return 'en';
}

function checkSystemNotification(osName) {
  try {
    if (osName === 'macOS') {
      return { available: true, method: 'osascript' };
    } else if (osName === 'Linux') {
      execSync('which notify-send', { stdio: 'ignore' });
      return { available: true, method: 'notify-send' };
    } else if (osName === 'Windows') {
      execSync('where powershell.exe', { stdio: 'ignore' });
      return { available: true, method: 'PowerShell' };
    }
  } catch (e) {
    return { available: false, method: null };
  }
  return { available: false, method: null };
}

async function selectOption(title, options, defaultIndex = 0) {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });

  console.log(`\n${BOLD}${title}${RESET}\n`);

  options.forEach((opt, i) => {
    const marker = i === defaultIndex ? `${CYAN}▶${RESET}` : ' ';
    const highlight = i === defaultIndex ? CYAN : DIM;
    console.log(`  ${marker} ${highlight}${i + 1}. ${opt.label}${RESET}`);
  });

  return new Promise((resolve) => {
    rl.question(`\n${DIM}Enter number [1-${options.length}]:${RESET} `, (answer) => {
      rl.close();
      const num = parseInt(answer) || (defaultIndex + 1);
      const idx = Math.max(0, Math.min(options.length - 1, num - 1));
      resolve({ value: options[idx].value, label: options[idx].label });
    });
  });
}

async function install() {
  console.log('');
  console.log(`${CYAN}╔════════════════════════════════════════════════════════════════╗${RESET}`);
  console.log(`${CYAN}║                                                                ║${RESET}`);
  console.log(`${CYAN}║${RESET}   ${BOLD}🎮 Claude Code Achievements${RESET}                                 ${CYAN}║${RESET}`);
  console.log(`${CYAN}║${RESET}   ${DIM}Level up your AI coding skills${RESET}                             ${CYAN}║${RESET}`);
  console.log(`${CYAN}║                                                                ║${RESET}`);
  console.log(`${CYAN}╚════════════════════════════════════════════════════════════════╝${RESET}`);
  console.log('');

  const detectedOS = detectOS();
  const detectedLang = detectLanguage();
  const notifyCheck = checkSystemNotification(detectedOS);

  // System info box
  console.log(`${DIM}┌─ System Info ─────────────────────────────────────────────────┐${RESET}`);
  console.log(`${DIM}│${RESET}  Platform:      ${BOLD}${detectedOS}${RESET}`);
  if (notifyCheck.available) {
    console.log(`${DIM}│${RESET}  Notifications: ${GREEN}✓ Available${RESET} ${DIM}(${notifyCheck.method})${RESET}`);
  } else {
    console.log(`${DIM}│${RESET}  Notifications: ${YELLOW}○ Terminal only${RESET}`);
  }
  console.log(`${DIM}└───────────────────────────────────────────────────────────────┘${RESET}`);

  const isInteractive = process.stdin.isTTY;

  let language = detectedLang;
  let notificationStyle = notifyCheck.available ? 'system' : 'terminal';

  if (isInteractive) {
    // Language selection
    const langResult = await selectOption(
      '🌍 Choose your language',
      [
        { label: '🇺🇸 English', value: 'en' },
        { label: '🇨🇳 中文', value: 'zh' },
        { label: '🇪🇸 Español', value: 'es' },
        { label: '🇰🇷 한국어', value: 'ko' },
        { label: '🇯🇵 日本語', value: 'ja' }
      ],
      ['en', 'zh', 'es', 'ko', 'ja'].indexOf(detectedLang)
    );
    language = langResult.value;
    console.log(`${GREEN}  ✓ Selected: ${langResult.label}${RESET}`);

    // Notification style
    if (notifyCheck.available) {
      const notifyResult = await selectOption(
        '🔔 Achievement notifications',
        [
          { label: `System popup (${notifyCheck.method})`, value: 'system' },
          { label: 'Terminal message', value: 'terminal' },
          { label: 'Both', value: 'both' }
        ],
        0
      );
      notificationStyle = notifyResult.value;
      console.log(`${GREEN}  ✓ Selected: ${notifyResult.label}${RESET}`);
    } else {
      console.log(`\n${DIM}🔔 Notifications: Terminal mode (system not available)${RESET}`);
    }
  }

  console.log('');
  console.log(`${DIM}───────────────────────────────────────────────────────────────${RESET}`);
  console.log(`${YELLOW}  ⏳ Installing plugin...${RESET}`);

  // Copy files
  const packageRoot = path.resolve(__dirname, '..');

  if (fs.existsSync(TARGET_DIR)) {
    fs.rmSync(TARGET_DIR, { recursive: true, force: true });
  }

  fs.mkdirSync(TARGET_DIR, { recursive: true });

  for (const item of ITEMS_TO_COPY) {
    const srcPath = path.join(packageRoot, item);
    const destPath = path.join(TARGET_DIR, item);
    if (fs.existsSync(srcPath)) {
      copyRecursive(srcPath, destPath);
    }
  }

  // Initialize state
  const stateDir = path.join(os.homedir(), '.claude', 'achievements');
  const stateFile = path.join(stateDir, 'state.json');

  if (!fs.existsSync(stateDir)) {
    fs.mkdirSync(stateDir, { recursive: true });
  }

  let existingState = null;
  if (fs.existsSync(stateFile)) {
    try {
      existingState = JSON.parse(fs.readFileSync(stateFile, 'utf8'));
    } catch (e) {}
  }

  const newState = {
    settings: {
      language,
      notifications: true,
      notification_style: notificationStyle
    },
    achievements: existingState?.achievements || {},
    counters: existingState?.counters || {},
    session: {}
  };

  fs.writeFileSync(stateFile, JSON.stringify(newState, null, 2));

  // Symlink commands
  const commandsDir = path.join(os.homedir(), '.claude', 'commands');
  if (!fs.existsSync(commandsDir)) {
    fs.mkdirSync(commandsDir, { recursive: true });
  }
  const pluginCommands = path.join(TARGET_DIR, 'commands');
  if (fs.existsSync(pluginCommands)) {
    for (const file of fs.readdirSync(pluginCommands)) {
      const linkPath = path.join(commandsDir, file);
      const targetPath = path.join(pluginCommands, file);

      if (fs.existsSync(linkPath)) {
        fs.unlinkSync(linkPath);
      }
      fs.symlinkSync(targetPath, linkPath);
    }
  }

  // Register hooks
  const settingsFile = path.join(os.homedir(), '.claude', 'settings.json');
  let settings = {};
  if (fs.existsSync(settingsFile)) {
    try {
      settings = JSON.parse(fs.readFileSync(settingsFile, 'utf8'));
    } catch (e) {}
  }

  if (!settings.enabledPlugins) settings.enabledPlugins = {};
  settings.enabledPlugins['claude-code-achievements@local'] = true;

  if (!settings.hooks) settings.hooks = {};

  const trackScript = path.join(TARGET_DIR, 'hooks', 'track-achievement.sh');
  const stopScript = path.join(TARGET_DIR, 'hooks', 'track-stop.sh');

  settings.hooks.PostToolUse = [
    {
      matcher: '.*',
      hooks: [{ type: 'command', command: trackScript, timeout: 5 }]
    }
  ];

  settings.hooks.Stop = [
    {
      matcher: '.*',
      hooks: [{ type: 'command', command: stopScript, timeout: 5 }]
    }
  ];

  fs.writeFileSync(settingsFile, JSON.stringify(settings, null, 2));

  // Count achievements if any exist
  const achievementCount = Object.keys(existingState?.achievements || {}).length;

  console.log(`${DIM}───────────────────────────────────────────────────────────────${RESET}`);
  console.log('');
  console.log(`${GREEN}${BOLD}  ✅ Installation complete!${RESET}`);
  console.log('');

  if (achievementCount > 0) {
    console.log(`${MAGENTA}  🏆 Welcome back! You have ${achievementCount} achievement${achievementCount > 1 ? 's' : ''} unlocked.${RESET}`);
    console.log('');
  }

  console.log(`${CYAN}╭──────────────────────────────────────────────────────────────╮${RESET}`);
  console.log(`${CYAN}│${RESET}  ${BOLD}Quick Start${RESET}                                                 ${CYAN}│${RESET}`);
  console.log(`${CYAN}│${RESET}                                                              ${CYAN}│${RESET}`);
  console.log(`${CYAN}│${RESET}  ${YELLOW}/achievements${RESET}          View your achievements             ${CYAN}│${RESET}`);
  console.log(`${CYAN}│${RESET}  ${YELLOW}/achievements locked${RESET}   See what's left to unlock          ${CYAN}│${RESET}`);
  console.log(`${CYAN}│${RESET}  ${YELLOW}/achievements-settings${RESET} Change language & notifications    ${CYAN}│${RESET}`);
  console.log(`${CYAN}│${RESET}                                                              ${CYAN}│${RESET}`);
  console.log(`${CYAN}╰──────────────────────────────────────────────────────────────╯${RESET}`);
  console.log('');
  console.log(`${DIM}  26 achievements await. Start coding to unlock them!${RESET}`);
  console.log('');
  console.log(`  ${BOLD}🎮 Happy coding!${RESET}`);
  console.log('');
}

install().catch(err => {
  console.error('❌ Installation failed:', err.message);
  process.exit(1);
});
