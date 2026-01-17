<div align="center">

<img src="assets/icon.png" alt="Claude Code Achievements" width="120" height="120">

# Claude Code Achievements

**Steam スタイルの Claude Code アチーブメントシステム**

[![npm version](https://img.shields.io/npm/v/claude-code-achievements.svg?style=flat-square&color=CB3837)](https://www.npmjs.com/package/claude-code-achievements)
[![license](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](LICENSE)
[![node](https://img.shields.io/badge/node-%3E%3D14.0.0-brightgreen.svg?style=flat-square)](package.json)

コーディングの旅をゲーム化し、Claude Code の機能をマスターしながらアチーブメントを解除しよう！

[インストール](#インストール) · [使い方](#使い方) · [アチーブメント](#アチーブメント) · [仕組み](#アーキテクチャ)

**[English](README.md)** · **[中文](README.zh.md)** · **[Español](README.es.md)** · **[한국어](README.ko.md)**

</div>

---

## 機能

- **26 のアチーブメント**、4 つのカテゴリに分類
- **リアルタイム通知**、システムアラートまたはターミナル経由
- **多言語サポート**（EN / 中文 / ES / 한국어 / 日本語）
- **クロスプラットフォーム**（macOS / Linux / Windows）
- **グローバルインストール** - すべてのプロジェクトで自動的に動作

## インストール

```bash
npx claude-code-achievements
```

インタラクティブインストーラーが：
1. OS と通知機能を自動検出
2. 言語設定を確認
3. 通知スタイルを設定（システム/ターミナル/両方）
4. `~/.claude/plugins/local/` にグローバルインストール

> **注意：** このプラグインは**グローバルインストール**され、すべてのプロジェクトで自動的に動作します。

### 手動インストール

```bash
git clone https://github.com/subinium/claude-code-achievements.git
cd claude-code-achievements
node bin/install.js
```

## 使い方

| コマンド | 説明 |
|----------|------|
| `/achievements` | 解除済みアチーブメントを表示（デフォルト） |
| `/achievements locked` | 未解除アチーブメントとヒントを表示 |
| `/achievements all` | カテゴリ別に全アチーブメントを表示 |
| `/achievements-settings` | 言語や通知設定を変更 |

### カテゴリフィルター

```bash
/achievements basics    # はじめに
/achievements workflow  # ワークフロー
/achievements tools     # パワーツール
/achievements mastery   # マスタリー
```

## アチーブメント

<details>
<summary><b>はじめに</b>（4 アチーブメント）</summary>

| アチーブメント | 解除方法 |
|----------------|----------|
| ✏️ **ファーストタッチ** | 任意のファイルを編集 |
| 📝 **クリエイター** | 新しいファイルを作成 |
| 🔍 **コードディテクティブ** | Glob または Grep でコードベースを検索 |
| 📋 **プロジェクトキュレーター** | `CLAUDE.md` を作成してプロジェクトコンテキストを設定 |

</details>

<details>
<summary><b>ワークフロー</b>（8 アチーブメント）</summary>

| アチーブメント | 解除方法 |
|----------------|----------|
| 📋 **タスクプランナー** | TodoWrite でタスク管理 |
| 🎯 **戦略的思考者** | Plan モードを使用（`Shift+Tab` を 2 回） |
| 🗣️ **コミュニケーター** | Claude が `AskUserQuestion` で要件を確認 |
| 🌍 **グローバルキュレーター** | `~/.claude/CLAUDE.md` を設定 |
| 📦 **バージョン管理者** | Claude と一緒にコミット |
| 🚀 **シップイット！** | リモートリポジトリにプッシュ |
| 🧪 **品質ガーディアン** | Claude と一緒にテストを実行 |
| 🚦 **CI/CD パイオニア** | GitHub Actions ワークフローを作成 |

</details>

<details>
<summary><b>パワーツール</b>（9 アチーブメント）</summary>

| アチーブメント | 解除方法 |
|----------------|----------|
| 🎨 **ビジュアルインスペクター** | 画像やスクリーンショットを分析 |
| 📡 **ドキュメントハンター** | Web ページを取得して分析 |
| 🤖 **デリゲーションマスター** | `Task` ツールでサブエージェントを使用 |
| 🔌 **MCP パイオニア** | 任意の MCP ツールを使用 |
| 🌐 **ウェブエクスプローラー** | `WebSearch` ツールを使用 |
| ⚡ **スキルマスター** | スラッシュコマンドスキルを使用 |
| ⚙️ **カスタマイザー** | Claude Code の設定を変更 |
| 📜 **スキルクリエイター** | `.claude/skills/` にカスタムスキルを作成 |
| ⌨️ **コマンドクラフター** | カスタムスラッシュコマンドを作成 |

</details>

<details>
<summary><b>マスタリー</b>（5 アチーブメント）</summary>

| アチーブメント | 解除方法 |
|----------------|----------|
| 🪝 **オートメーションアーキテクト** | Claude Code フックを設定 |
| 🔗 **MCP コネクター** | `.mcp.json` で統合を設定 |
| 🤖 **エージェントアーキテクト** | `.claude/agents/` にカスタムエージェントを作成 |
| 🛡️ **セキュリティガード** | セキュリティ権限を設定 |
| 🔄 **ループマスター** | 自律コーディングループを開始 |

</details>

---

## アーキテクチャ

このプラグインは **Claude Code のフックシステム** を使用してアクションをリアルタイムで追跡します。

```
┌─────────────────────────────────────────────────────────────┐
│                   CLAUDE CODE セッション                     │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   あなた: 「設定ファイルを編集して」                          │
│                     │                                        │
│                     ▼                                        │
│   ┌─────────────────────────────────────┐                   │
│   │       Claude が Edit ツールを使用    │                   │
│   └─────────────────────────────────────┘                   │
│                     │                                        │
│                     ▼                                        │
│   ┌─────────────────────────────────────┐                   │
│   │    PostToolUse フックがトリガー      │◄── hooks.json    │
│   │    → track-achievement.sh            │                   │
│   └─────────────────────────────────────┘                   │
│                     │                                        │
│         ┌──────────┴──────────┐                             │
│         ▼                     ▼                             │
│   ┌───────────┐        ┌───────────┐                        │
│   │  マッチ！  │        │ マッチなし │                       │
│   │           │        │           │                        │
│   │ 解除      │        │ 継続      │                        │
│   │ 通知      │        └───────────┘                        │
│   │ 保存      │                                              │
│   └───────────┘                                              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### プラグイン構造

```
~/.claude/plugins/local/claude-code-achievements/
├── .claude-plugin/
│   └── plugin.json          # プラグインメタデータ
├── hooks/
│   ├── hooks.json           # フック定義 (PostToolUse, Stop)
│   ├── track-achievement.sh # メイン追跡ロジック
│   └── track-stop.sh        # セッション終了ハンドラー
├── commands/
│   ├── achievements.md      # /achievements コマンド
│   └── achievements-settings.md
├── scripts/
│   ├── show-achievements.sh # 表示 UI
│   └── show-notification.sh # 通知ハンドラー
└── data/
    ├── achievements.json    # アチーブメント定義
    └── i18n/
        ├── en.json          # English
        ├── zh.json          # 中文
        ├── es.json          # Español
        ├── ko.json          # 한국어
        └── ja.json          # 日本語
```

### フックの仕組み

プラグインは Claude Code に 2 つのフックを登録します：

| フック | トリガー | 目的 |
|--------|----------|------|
| `PostToolUse` | ツール実行後 | アチーブメント条件の確認 |
| `Stop` | セッション終了時 | セッション統計の保存 |

### コマンドの仕組み

スラッシュコマンド（`/achievements`）は `~/.claude/commands/` にある**マークダウンファイル**として実装されています。

---

## 通知

インストール時にシステム通知が自動検出されます：

| OS | 方法 | サウンド |
|----|------|----------|
| macOS | `osascript` | Glass |
| Linux | `notify-send` | システムデフォルト |
| Windows | PowerShell | システムデフォルト |
| フォールバック | ターミナル | なし |

### Linux で notify-send をインストール

```bash
# Ubuntu/Debian
sudo apt install libnotify-bin

# Fedora
sudo dnf install libnotify

# Arch
sudo pacman -S libnotify
```

---

## 設定

設定は `~/.claude/achievements/state.json` に保存されます：

```json
{
  "settings": {
    "language": "ja",
    "notifications": true,
    "notification_style": "system"
  },
  "achievements": {},
  "counters": {}
}
```

| 設定 | 値 | 説明 |
|------|-----|------|
| `language` | `"en"`, `"zh"`, `"es"`, `"ko"`, `"ja"` | UI 言語 |
| `notifications` | `true`, `false` | アラートの有効/無効 |
| `notification_style` | `"system"`, `"terminal"`, `"both"` | アラート方法 |

---

## トラブルシューティング

<details>
<summary><b>アチーブメントが解除されない？</b></summary>

```bash
# プラグインがインストールされているか確認
ls ~/.claude/plugins/local/claude-code-achievements/

# 状態ファイルが存在するか確認
cat ~/.claude/achievements/state.json

# インストール後に Claude Code を再起動してフックをロード
```

</details>

<details>
<summary><b>進捗をリセット</b></summary>

```bash
rm ~/.claude/achievements/state.json
```

</details>

<details>
<summary><b>プラグインを再インストール</b></summary>

```bash
npx claude-code-achievements@latest
```

</details>

---

## 貢献

貢献を歓迎します！アイデア：

- 新しいアチーブメント
- 新しい言語翻訳
- UI の改善
- バグ修正

## ライセンス

MIT © [subinium](https://github.com/subinium)

---

<div align="center">

**Happy coding!**

</div>
