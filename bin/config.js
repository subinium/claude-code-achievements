#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const os = require('os');

const STATE_FILE = path.join(os.homedir(), '.claude', 'achievements', 'state.json');

// ANSI escape codes
const ESC = '\x1b';
const CLEAR_SCREEN = `${ESC}[2J${ESC}[H`;
const HIDE_CURSOR = `${ESC}[?25l`;
const SHOW_CURSOR = `${ESC}[?25h`;
const BOLD = `${ESC}[1m`;
const DIM = `${ESC}[2m`;
const RESET = `${ESC}[0m`;
const CYAN = `${ESC}[36m`;
const GREEN = `${ESC}[32m`;
const YELLOW = `${ESC}[33m`;
const WHITE = `${ESC}[37m`;
const BG_GRAY = `${ESC}[48;5;236m`;

// Box drawing
const BOX = {
  topLeft: '╭',
  topRight: '╮',
  bottomLeft: '╰',
  bottomRight: '╯',
  horizontal: '─',
  vertical: '│'
};

// Load state
function loadState() {
  try {
    return JSON.parse(fs.readFileSync(STATE_FILE, 'utf8'));
  } catch {
    return {
      settings: { language: 'en', notifications: true, notification_style: 'terminal' },
      achievements: {},
      counters: { ralph_iterations: 0, files_read: 0, edits_made: 0 },
      session: { files_read_set: [], ralph_loop_active: false }
    };
  }
}

// Save state
function saveState(state) {
  const dir = path.dirname(STATE_FILE);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  fs.writeFileSync(STATE_FILE, JSON.stringify(state, null, 2));
}

// Get terminal width
function getTermWidth() {
  return process.stdout.columns || 80;
}

// Settings definition
function getSettings(state) {
  return [
    {
      id: 'language',
      label: 'Language',
      value: state.settings.language === 'ko' ? '한국어' : 'English',
      options: [
        { id: 'en', label: 'English' },
        { id: 'ko', label: '한국어' }
      ]
    },
    {
      id: 'notifications',
      label: 'Notifications',
      value: state.settings.notifications ? 'On' : 'Off',
      options: [
        { id: true, label: 'On' },
        { id: false, label: 'Off' }
      ]
    },
    {
      id: 'notification_style',
      label: 'Notification style',
      value: state.settings.notification_style || 'terminal',
      options: [
        { id: 'terminal', label: 'terminal' },
        { id: 'system', label: 'system' },
        { id: 'both', label: 'both' }
      ]
    },
    {
      id: 'reset',
      label: 'Reset all progress',
      value: '',
      options: [
        { id: 'yes', label: 'Yes, reset' },
        { id: 'no', label: 'Cancel' }
      ]
    }
  ];
}

// Config UI
class ConfigUI {
  constructor() {
    this.state = loadState();
    this.settings = getSettings(this.state);
    this.selected = 0;
    this.editMode = false;
    this.editIndex = 0;
  }

  render() {
    const width = Math.min(getTermWidth() - 4, 100);
    let output = CLEAR_SCREEN;

    // Title
    output += `\n  ${BOLD}Configure Vibecoding Achievements${RESET}\n\n`;

    // Search box (decorative)
    const searchWidth = width - 2;
    output += `  ${BOX.topLeft}${BOX.horizontal.repeat(searchWidth)}${BOX.topRight}\n`;
    output += `  ${BOX.vertical} ${DIM}⌕ Search settings...${' '.repeat(searchWidth - 21)}${RESET}${BOX.vertical}\n`;
    output += `  ${BOX.bottomLeft}${BOX.horizontal.repeat(searchWidth)}${BOX.bottomRight}\n\n`;

    // Settings list
    this.settings.forEach((setting, index) => {
      const isSelected = index === this.selected;
      const prefix = isSelected ? `${GREEN}❯${RESET}` : ' ';

      const labelWidth = 35;
      const label = setting.label.padEnd(labelWidth);

      let valueDisplay = setting.value;
      if (this.editMode && index === this.selected) {
        // Show options in edit mode
        const opts = setting.options;
        valueDisplay = opts.map((opt, i) => {
          if (i === this.editIndex) {
            return `${GREEN}${BOLD}${opt.label}${RESET}`;
          }
          return `${DIM}${opt.label}${RESET}`;
        }).join('  ');
      } else {
        valueDisplay = `${DIM}${setting.value}${RESET}`;
      }

      if (isSelected && !this.editMode) {
        output += `  ${prefix} ${BOLD}${label}${RESET}${valueDisplay}\n`;
      } else {
        output += `  ${prefix} ${label}${valueDisplay}\n`;
      }
    });

    // Help
    output += `\n  ${DIM}↑/↓: Navigate  Enter: Edit  ←/→: Change value  q: Quit${RESET}\n`;

    process.stdout.write(output);
  }

  async run() {
    if (!process.stdin.isTTY) {
      console.log('This command requires an interactive terminal.');
      console.log('Current settings:');
      console.log(JSON.stringify(this.state.settings, null, 2));
      return;
    }

    process.stdin.setRawMode(true);
    process.stdin.resume();
    process.stdin.setEncoding('utf8');
    process.stdout.write(HIDE_CURSOR);

    this.render();

    return new Promise((resolve) => {
      const cleanup = () => {
        process.stdin.setRawMode(false);
        process.stdin.pause();
        process.stdout.write(SHOW_CURSOR);
        process.stdout.write(CLEAR_SCREEN);
      };

      process.stdin.on('data', (key) => {
        // Ctrl+C or q
        if (key === '\u0003' || (key === 'q' && !this.editMode)) {
          cleanup();
          resolve();
          return;
        }

        // Escape - exit edit mode
        if (key === '\u001b' && this.editMode) {
          this.editMode = false;
          this.render();
          return;
        }

        if (this.editMode) {
          const setting = this.settings[this.selected];
          const opts = setting.options;

          // Left arrow
          if (key === '\u001b[D') {
            this.editIndex = Math.max(0, this.editIndex - 1);
            this.render();
          }
          // Right arrow
          else if (key === '\u001b[C') {
            this.editIndex = Math.min(opts.length - 1, this.editIndex + 1);
            this.render();
          }
          // Enter - apply selection
          else if (key === '\r' || key === '\n') {
            this.applyChange(setting.id, opts[this.editIndex].id);
            this.editMode = false;
            this.settings = getSettings(this.state);
            this.render();
          }
        } else {
          // Up arrow
          if (key === '\u001b[A') {
            this.selected = Math.max(0, this.selected - 1);
            this.render();
          }
          // Down arrow
          else if (key === '\u001b[B') {
            this.selected = Math.min(this.settings.length - 1, this.selected + 1);
            this.render();
          }
          // Enter - enter edit mode
          else if (key === '\r' || key === '\n') {
            const setting = this.settings[this.selected];
            this.editMode = true;
            // Set editIndex to current value
            const currentVal = this.state.settings[setting.id];
            this.editIndex = setting.options.findIndex(o => o.id === currentVal);
            if (this.editIndex === -1) this.editIndex = 0;
            this.render();
          }
          // Left/Right - quick toggle
          else if (key === '\u001b[D' || key === '\u001b[C') {
            const setting = this.settings[this.selected];
            const opts = setting.options;
            const currentVal = this.state.settings[setting.id];
            let idx = opts.findIndex(o => o.id === currentVal);
            if (idx === -1) idx = 0;

            if (key === '\u001b[C') {
              idx = Math.min(opts.length - 1, idx + 1);
            } else {
              idx = Math.max(0, idx - 1);
            }

            this.applyChange(setting.id, opts[idx].id);
            this.settings = getSettings(this.state);
            this.render();
          }
        }
      });
    });
  }

  applyChange(settingId, value) {
    if (settingId === 'reset') {
      if (value === 'yes') {
        this.state.achievements = {};
        this.state.counters = { ralph_iterations: 0, files_read: 0, edits_made: 0 };
        this.state.session = { files_read_set: [], ralph_loop_active: false };
      }
    } else {
      this.state.settings[settingId] = value;
    }
    saveState(this.state);
  }
}

// Run
const ui = new ConfigUI();
ui.run().catch(err => {
  process.stdout.write(SHOW_CURSOR);
  console.error(err);
  process.exit(1);
});
