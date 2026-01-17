<div align="center">

<img src="assets/icon.png" alt="Claude Code Achievements" width="120" height="120">

# Claude Code Achievements

**Sistema de logros estilo Steam para Claude Code**

[![npm version](https://img.shields.io/npm/v/claude-code-achievements.svg?style=flat-square&color=CB3837)](https://www.npmjs.com/package/claude-code-achievements)
[![license](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](LICENSE)
[![node](https://img.shields.io/badge/node-%3E%3D14.0.0-brightgreen.svg?style=flat-square)](package.json)

¡Gamifica tu experiencia de programación y desbloquea logros mientras dominas las funciones de Claude Code!

[Instalación](#instalación) · [Uso](#uso) · [Logros](#logros) · [Cómo Funciona](#arquitectura)

**[English](README.md)** · **[中文](README.zh.md)** · **[한국어](README.ko.md)** · **[日本語](README.ja.md)**

</div>

---

## Características

- **26 Logros** en 4 categorías
- **Notificaciones en tiempo real** vía alertas del sistema o terminal
- **Soporte multiidioma** (EN / 中文 / ES / 한국어 / 日本語)
- **Multiplataforma** (macOS / Linux / Windows)
- **Instalación global** - funciona en todos tus proyectos

## Instalación

```bash
npx claude-code-achievements
```

El instalador interactivo:
1. Detectará automáticamente tu SO y capacidad de notificaciones
2. Preguntará tu preferencia de idioma
3. Configurará el estilo de notificación (sistema/terminal/ambos)
4. Instalará globalmente en `~/.claude/plugins/local/`

> **Nota:** Este plugin se instala **globalmente** y funciona automáticamente en todos tus proyectos.

### Instalación Manual

```bash
git clone https://github.com/subinium/claude-code-achievements.git
cd claude-code-achievements
node bin/install.js
```

## Uso

| Comando | Descripción |
|---------|-------------|
| `/achievements` | Ver logros desbloqueados (predeterminado) |
| `/achievements locked` | Ver logros bloqueados con pistas |
| `/achievements all` | Ver todos los logros por categoría |
| `/achievements-settings` | Cambiar idioma o configuración de notificaciones |

### Filtros de Categoría

```bash
/achievements basics    # Primeros Pasos
/achievements workflow  # Flujo de Trabajo
/achievements tools     # Herramientas Avanzadas
/achievements mastery   # Maestría
```

## Logros

<details>
<summary><b>Primeros Pasos</b> (4 logros)</summary>

| Logro | Cómo Desbloquear |
|-------|------------------|
| ✏️ **Primer Toque** | Editar cualquier archivo |
| 📝 **Creador** | Crear un nuevo archivo |
| 🔍 **Detective de Código** | Usar Glob o Grep para buscar en el código |
| 📋 **Curador de Proyecto** | Crear `CLAUDE.md` para contexto del proyecto |

</details>

<details>
<summary><b>Flujo de Trabajo</b> (8 logros)</summary>

| Logro | Cómo Desbloquear |
|-------|------------------|
| 📋 **Planificador de Tareas** | Usar TodoWrite para seguimiento de tareas |
| 🎯 **Pensador Estratégico** | Usar modo Plan (`Shift+Tab` dos veces) |
| 🗣️ **Comunicador** | Claude usa `AskUserQuestion` para clarificar requisitos |
| 🌍 **Curador Global** | Configurar `~/.claude/CLAUDE.md` |
| 📦 **Controlador de Versiones** | Hacer commit con Claude |
| 🚀 **¡A Producción!** | Hacer push al repositorio remoto |
| 🧪 **Guardián de Calidad** | Ejecutar tests con Claude |
| 🚦 **Pionero CI/CD** | Crear workflow de GitHub Actions |

</details>

<details>
<summary><b>Herramientas Avanzadas</b> (9 logros)</summary>

| Logro | Cómo Desbloquear |
|-------|------------------|
| 🎨 **Inspector Visual** | Analizar imagen o captura de pantalla |
| 📡 **Cazador de Docs** | Obtener y analizar una página web |
| 🤖 **Maestro de Delegación** | Usar herramienta `Task` para sub-agentes |
| 🔌 **Pionero MCP** | Usar cualquier herramienta MCP |
| 🌐 **Explorador Web** | Usar herramienta `WebSearch` |
| ⚙️ **Personalizador** | Modificar configuración de Claude Code |
| 📜 **Creador de Skills** | Crear skill personalizado en `.claude/skills/` |
| ⌨️ **Artesano de Comandos** | Crear comando slash personalizado |
| 🧩 **Explorador de Plugins** | Instalar un plugin desde el marketplace |

</details>

<details>
<summary><b>Maestría</b> (5 logros)</summary>

| Logro | Cómo Desbloquear |
|-------|------------------|
| 🪝 **Arquitecto de Automatización** | Configurar hooks de Claude Code |
| 🔗 **Conector MCP** | Configurar `.mcp.json` para integraciones |
| 🤖 **Arquitecto de Agentes** | Crear agente personalizado en `.claude/agents/` |
| 🛡️ **Guardia de Seguridad** | Configurar permisos de seguridad |
| 🔄 **Maestro del Bucle** | Iniciar bucle de codificación autónomo |

</details>

---

## Arquitectura

Este plugin usa el **sistema de hooks de Claude Code** para rastrear tus acciones en tiempo real.

```
┌─────────────────────────────────────────────────────────────┐
│                     SESIÓN DE CLAUDE CODE                    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   Tú: "Edita el archivo de configuración"                   │
│                     │                                        │
│                     ▼                                        │
│   ┌─────────────────────────────────────┐                   │
│   │      Claude usa la herramienta Edit  │                   │
│   └─────────────────────────────────────┘                   │
│                     │                                        │
│                     ▼                                        │
│   ┌─────────────────────────────────────┐                   │
│   │    Se activa el Hook PostToolUse    │◄── hooks.json     │
│   │    → track-achievement.sh            │                   │
│   └─────────────────────────────────────┘                   │
│                     │                                        │
│         ┌──────────┴──────────┐                             │
│         ▼                     ▼                             │
│   ┌───────────┐        ┌───────────┐                        │
│   │ ¡Coincide!│        │ No coincide│                       │
│   │           │        │           │                        │
│   │ Desbloquear│       │ Continuar │                        │
│   │ Notificar │        └───────────┘                        │
│   │ Guardar   │                                              │
│   └───────────┘                                              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Estructura del Plugin

```
~/.claude/plugins/local/claude-code-achievements/
├── .claude-plugin/
│   └── plugin.json          # Metadatos del plugin
├── hooks/
│   ├── hooks.json           # Definiciones de hooks (PostToolUse, Stop)
│   ├── track-achievement.sh # Lógica principal de seguimiento
│   └── track-stop.sh        # Manejador de fin de sesión
├── commands/
│   ├── achievements.md      # Comando /achievements
│   └── achievements-settings.md
├── scripts/
│   ├── show-achievements.sh # UI de visualización
│   └── show-notification.sh # Manejador de notificaciones
└── data/
    ├── achievements.json    # Definiciones de logros
    └── i18n/
        ├── en.json          # English
        ├── zh.json          # 中文
        ├── es.json          # Español
        ├── ko.json          # 한국어
        └── ja.json          # 日本語
```

### Cómo Funcionan los Hooks

El plugin registra dos hooks en Claude Code:

| Hook | Activador | Propósito |
|------|-----------|-----------|
| `PostToolUse` | Después de ejecutar herramienta | Verificar condiciones de logro |
| `Stop` | Al finalizar sesión | Guardar estadísticas de sesión |

### Cómo Funcionan los Comandos

Los comandos slash (`/achievements`) se implementan como **archivos Markdown** en `~/.claude/commands/`.

---

## Notificaciones

Las notificaciones del sistema se detectan automáticamente durante la instalación:

| SO | Método | Sonido |
|----|--------|--------|
| macOS | `osascript` | Glass |
| Linux | `notify-send` | Predeterminado del sistema |
| Windows | PowerShell | Predeterminado del sistema |
| Alternativa | Terminal | Ninguno |

### Instalar notify-send en Linux

```bash
# Ubuntu/Debian
sudo apt install libnotify-bin

# Fedora
sudo dnf install libnotify

# Arch
sudo pacman -S libnotify
```

---

## Configuración

La configuración se guarda en `~/.claude/achievements/state.json`:

```json
{
  "settings": {
    "language": "es",
    "notifications": true,
    "notification_style": "system"
  },
  "achievements": {},
  "counters": {}
}
```

| Configuración | Valores | Descripción |
|---------------|---------|-------------|
| `language` | `"en"`, `"zh"`, `"es"`, `"ko"`, `"ja"` | Idioma de la interfaz |
| `notifications` | `true`, `false` | Activar/desactivar alertas |
| `notification_style` | `"system"`, `"terminal"`, `"both"` | Método de alerta |

---

## Solución de Problemas

<details>
<summary><b>¿Los logros no se desbloquean?</b></summary>

```bash
# Verificar que el plugin está instalado
ls ~/.claude/plugins/local/claude-code-achievements/

# Verificar que existe el archivo de estado
cat ~/.claude/achievements/state.json

# Reiniciar Claude Code después de la instalación para cargar los hooks
```

</details>

<details>
<summary><b>Reiniciar todo el progreso</b></summary>

```bash
rm ~/.claude/achievements/state.json
```

</details>

<details>
<summary><b>Reinstalar el plugin</b></summary>

```bash
npx claude-code-achievements@latest
```

</details>

---

## Contribuir

¡Las contribuciones son bienvenidas! Ideas:

- Nuevos logros
- Nuevas traducciones de idiomas
- Mejoras de UI
- Corrección de errores

## Licencia

MIT © [subinium](https://github.com/subinium)

---

<div align="center">

**¡Feliz programación!**

</div>
