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
const RED = '\x1b[31m';
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
      // macOS always has osascript
      return { available: true, method: 'osascript' };
    } else if (osName === 'Linux') {
      // Check for notify-send
      execSync('which notify-send', { stdio: 'ignore' });
      return { available: true, method: 'notify-send' };
    } else if (osName === 'Windows') {
      // Check for PowerShell
      execSync('where powershell.exe', { stdio: 'ignore' });
      return { available: true, method: 'PowerShell' };
    }
  } catch (e) {
    return { available: false, method: null };
  }
  return { available: false, method: null };
}


async function prompt(question, options) {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });

  return new Promise((resolve) => {
    const optStr = options.map((o, i) => `${i + 1}) ${o.label}`).join('  ');
    rl.question(`${question} [${optStr}]: `, (answer) => {
      rl.close();
      const num = parseInt(answer) || 1;
      const idx = Math.max(0, Math.min(options.length - 1, num - 1));
      resolve(options[idx].value);
    });
  });
}

async function install() {
  console.log('');
  console.log(`${CYAN}${BOLD}╔═══════════════════════════════════════════════════════════╗${RESET}`);
  console.log(`${CYAN}${BOLD}║       🎮 Claude Code Achievements Installer 🎮            ║${RESET}`);
  console.log(`${CYAN}${BOLD}╚═══════════════════════════════════════════════════════════╝${RESET}`);
  console.log('');

  const detectedOS = detectOS();
  const detectedLang = detectLanguage();
  const notifyCheck = checkSystemNotification(detectedOS);

  console.log(`${DIM}Detected OS: ${detectedOS}${RESET}`);
  if (notifyCheck.available) {
    console.log(`${DIM}System notifications: ${GREEN}✓${RESET}${DIM} ${notifyCheck.method}${RESET}`);
  } else {
    console.log(`${DIM}System notifications: ${YELLOW}✗${RESET}${DIM} not available (will use terminal)${RESET}`);
  }
  console.log('');

  // Check if interactive
  const isInteractive = process.stdin.isTTY;

  let language = detectedLang;
  let notificationStyle = notifyCheck.available ? 'system' : 'terminal';

  if (isInteractive) {
    // Language selection
    console.log(`${BOLD}Select language / 选择语言 / Idioma / 언어 / 言語:${RESET}`);
    language = await prompt('', [
      { label: 'English', value: 'en' },
      { label: '中文', value: 'zh' },
      { label: 'Español', value: 'es' },
      { label: '한국어', value: 'ko' },
      { label: '日本語', value: 'ja' }
    ]);
    const langNames = { en: 'English', zh: '中文', es: 'Español', ko: '한국어', ja: '日本語' };
    console.log(`  ${GREEN}✓${RESET} ${langNames[language]}`);
    console.log('');

    // Notification style (only ask if system notifications available)
    if (notifyCheck.available) {
      console.log(`${BOLD}Notification style:${RESET}`);
      notificationStyle = await prompt('', [
        { label: `System (${notifyCheck.method})`, value: 'system' },
        { label: 'Terminal', value: 'terminal' },
        { label: 'Both', value: 'both' }
      ]);
      console.log(`  ${GREEN}✓${RESET} ${notificationStyle}`);
    } else {
      console.log(`${BOLD}Notification:${RESET} Terminal (system not available)`);
      notificationStyle = 'terminal';
    }
    console.log('');
  }

  // Copy files
  const packageRoot = path.resolve(__dirname, '..');

  if (fs.existsSync(TARGET_DIR)) {
    console.log(`${DIM}Removing existing installation...${RESET}`);
    fs.rmSync(TARGET_DIR, { recursive: true, force: true });
  }

  console.log(`${DIM}Installing to ${TARGET_DIR}${RESET}`);
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

  // Always update settings, preserve achievements if exists
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

  // Symlink commands to ~/.claude/commands/ for short command names (/achievements)
  // Plugin also provides namespaced commands (/claude-code-achievements:achievements)
  const commandsDir = path.join(os.homedir(), '.claude', 'commands');
  if (!fs.existsSync(commandsDir)) {
    fs.mkdirSync(commandsDir, { recursive: true });
  }
  const pluginCommands = path.join(TARGET_DIR, 'commands');
  if (fs.existsSync(pluginCommands)) {
    for (const file of fs.readdirSync(pluginCommands)) {
      const linkPath = path.join(commandsDir, file);
      const targetPath = path.join(pluginCommands, file);

      // Remove existing file/symlink if exists
      if (fs.existsSync(linkPath)) {
        fs.unlinkSync(linkPath);
      }

      // Create symlink
      fs.symlinkSync(targetPath, linkPath);
    }
  }

  // Register hooks in ~/.claude/settings.json
  const settingsFile = path.join(os.homedir(), '.claude', 'settings.json');
  let settings = {};
  if (fs.existsSync(settingsFile)) {
    try {
      settings = JSON.parse(fs.readFileSync(settingsFile, 'utf8'));
    } catch (e) {}
  }

  // Add plugin to enabledPlugins
  if (!settings.enabledPlugins) settings.enabledPlugins = {};
  settings.enabledPlugins['claude-code-achievements@local'] = true;

  // Add hooks (replace any existing achievement hooks)
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

  console.log('');
  console.log(`${GREEN}${BOLD}✅ Installation complete!${RESET}`);
  console.log('');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('');
  console.log(`${BOLD}Ready to use:${RESET}`);
  console.log('');
  console.log(`  ${CYAN}/achievements${RESET}       View your achievements`);
  console.log(`  ${CYAN}/achievements hint${RESET}  Get tips for unlocking`);
  console.log('');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('');
  console.log('🎮 Happy coding!');
  console.log('');
}

install().catch(err => {
  console.error('❌ Installation failed:', err.message);
  process.exit(1);
});
