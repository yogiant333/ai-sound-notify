# AI Sound Notify Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a WebSocket-based notification system that plays distinct browser sounds when Claude Code, Gemini CLI, or Codex CLI complete tasks or need user input.

**Architecture:** Node.js server (Express + ws) receives HTTP POST from AI hooks, pushes to browser via WebSocket. Browser synthesizes sounds via Web Audio API with distinct frequencies per AI source and event type.

**Tech Stack:** Node.js, Express, ws, vanilla HTML/CSS/JS, Web Audio API

---

### Task 1: Project Scaffolding

**Files:**
- Create: `server/package.json`
- Create: `.gitignore`
- Create: `LICENSE`

**Step 1: Initialize git repo**

```bash
cd /mnt/d/AI/ai-sound-notify
git init
```

**Step 2: Create server/package.json**

```json
{
  "name": "ai-sound-notify",
  "version": "1.0.0",
  "description": "Sound notification system for AI coding agents",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "dev": "node index.js"
  },
  "dependencies": {
    "express": "^4.21.0",
    "ws": "^8.18.0"
  }
}
```

**Step 3: Create .gitignore**

```
node_modules/
.DS_Store
*.log
```

**Step 4: Create LICENSE (MIT)**

**Step 5: Install dependencies**

```bash
cd server && npm install
```

**Step 6: Commit**

```bash
git add -A
git commit -m "chore: project scaffolding with package.json and gitignore"
```

---

### Task 2: Node.js Notification Server

**Files:**
- Create: `server/index.js`

**Step 1: Write the server**

The server needs:
- Express app on port 9800
- `POST /notify` endpoint accepting `{ source, event, message?, session_id? }`
- Validate source is one of: claude-code, gemini, codex
- Validate event is one of: task_complete, need_input
- WebSocket server on same HTTP server
- Broadcast incoming notifications to all connected WebSocket clients
- `GET /` serves `../web/index.html`
- `GET /api/health` health check endpoint
- CORS headers for flexibility

**Step 2: Test manually**

```bash
cd server && node index.js &
curl -X POST http://localhost:9800/notify \
  -H 'Content-Type: application/json' \
  -d '{"source":"claude-code","event":"task_complete","message":"test"}'
```

Expected: 200 OK with `{"ok":true}`

**Step 3: Test invalid input**

```bash
curl -X POST http://localhost:9800/notify \
  -H 'Content-Type: application/json' \
  -d '{"source":"unknown","event":"bad"}'
```

Expected: 400 with error message

**Step 4: Commit**

```bash
git add server/index.js
git commit -m "feat: add notification server with Express and WebSocket"
```

---

### Task 3: Browser Notification Page

**Files:**
- Create: `web/index.html`

**Step 1: Build the single-file HTML page**

This is a self-contained HTML file with inline CSS and JS. Features:

**CSS/Layout:**
- Dark theme, responsive layout
- Header with title, connection status indicator, volume slider, mute button
- Three AI source cards (Claude=purple, Gemini=blue, Codex=green) with toggle switches
- Notification history list (newest first, max 50 items)
- Each notification shows: timestamp, source badge (colored), event type, message
- 6 sound test buttons (one per source+event combo)

**JavaScript:**
- WebSocket connection to `ws://HOST:9800` with auto-reconnect (3s interval)
- Connection status indicator (green=connected, red=disconnected)
- Web Audio API sound synthesis:
  - `claude-code` + `task_complete`: 880Hz rising sine, 0.3s
  - `claude-code` + `need_input`: 880Hz double beep, 0.15s x2
  - `gemini` + `task_complete`: 660Hz rising sine, 0.3s
  - `gemini` + `need_input`: 660Hz double beep, 0.15s x2
  - `codex` + `task_complete`: 440Hz rising sine, 0.3s
  - `codex` + `need_input`: 440Hz double beep, 0.15s x2
- Volume control via GainNode
- Per-source mute toggles
- Notification history array, render as list items
- Browser Notification API (optional, with permission request)

**Step 2: Test in browser**

Open `http://localhost:9800` — page should load, WebSocket should connect (green indicator).

**Step 3: Test sound buttons**

Click each of the 6 test buttons. Each should play a distinct sound.

**Step 4: Commit**

```bash
git add web/index.html
git commit -m "feat: add browser notification page with Web Audio sounds"
```

---

### Task 4: Integration Test Scripts

**Files:**
- Create: `scripts/notify.sh`
- Create: `scripts/test-notify.sh`

**Step 1: Create notify.sh (generic helper)**

```bash
#!/bin/bash
# Usage: ./notify.sh <source> <event> [message]
# Example: ./notify.sh claude-code task_complete "Build finished"

SERVER="${AI_NOTIFY_SERVER:-http://localhost:9800}"
SOURCE="${1:?Usage: notify.sh <source> <event> [message]}"
EVENT="${2:?Usage: notify.sh <source> <event> [message]}"
MESSAGE="${3:-}"

curl -s -X POST "$SERVER/notify" \
  -H 'Content-Type: application/json' \
  -d "{\"source\":\"$SOURCE\",\"event\":\"$EVENT\",\"message\":\"$MESSAGE\"}"
```

**Step 2: Create test-notify.sh**

```bash
#!/bin/bash
# Sends all 6 notification types with 2s delay between each
SERVER="${AI_NOTIFY_SERVER:-http://localhost:9800}"

echo "Testing all 6 notification types..."

for source in claude-code gemini codex; do
  for event in task_complete need_input; do
    echo "  -> $source / $event"
    curl -s -X POST "$SERVER/notify" \
      -H 'Content-Type: application/json' \
      -d "{\"source\":\"$source\",\"event\":\"$event\",\"message\":\"Test: $source $event\"}"
    sleep 2
  done
done

echo "Done!"
```

**Step 3: Make executable and test**

```bash
chmod +x scripts/notify.sh scripts/test-notify.sh
./scripts/test-notify.sh
```

Expected: 6 notifications appear in browser with distinct sounds.

**Step 4: Commit**

```bash
git add scripts/
git commit -m "feat: add notification helper and test scripts"
```

---

### Task 5: Configuration Examples

**Files:**
- Create: `configs/claude-code.json`
- Create: `configs/gemini.json`
- Create: `configs/codex.toml`

**Step 1: Create Claude Code config example**

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "curl -s -X POST http://localhost:9800/notify -H 'Content-Type: application/json' -d '{\"source\":\"claude-code\",\"event\":\"task_complete\"}'",
            "timeout": 5
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "idle_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "curl -s -X POST http://localhost:9800/notify -H 'Content-Type: application/json' -d '{\"source\":\"claude-code\",\"event\":\"need_input\",\"message\":\"Claude is idle, needs your input\"}'",
            "timeout": 5
          }
        ]
      },
      {
        "matcher": "permission_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "curl -s -X POST http://localhost:9800/notify -H 'Content-Type: application/json' -d '{\"source\":\"claude-code\",\"event\":\"need_input\",\"message\":\"Claude needs permission\"}'",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

**Step 2: Create Gemini CLI config example**

```json
{
  "hooks": {
    "AfterAgent": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "curl -s -X POST http://localhost:9800/notify -H 'Content-Type: application/json' -d '{\"source\":\"gemini\",\"event\":\"task_complete\"}'",
            "timeout": 5000
          }
        ]
      }
    ],
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "curl -s -X POST http://localhost:9800/notify -H 'Content-Type: application/json' -d '{\"source\":\"gemini\",\"event\":\"need_input\"}'",
            "timeout": 5000
          }
        ]
      }
    ]
  }
}
```

**Step 3: Create Codex CLI config example**

```toml
# Add to ~/.codex/config.toml
notify = ["bash", "-c", "curl -s -X POST http://localhost:9800/notify -H 'Content-Type: application/json' -d '{\"source\":\"codex\",\"event\":\"task_complete\"}'"]

[tui]
notifications = true
```

**Step 4: Commit**

```bash
git add configs/
git commit -m "feat: add hook configuration examples for all 3 AI tools"
```

---

### Task 6: README Documentation

**Files:**
- Create: `README.md`

**Step 1: Write comprehensive README**

Sections:
1. Project title + one-line description
2. Features list
3. Quick Start (3 steps: clone, npm install, npm start)
4. How It Works (architecture diagram)
5. Configuration Guide
   - Claude Code (copy JSON to settings.json)
   - Gemini CLI (copy JSON to settings.json)
   - Codex CLI (add to config.toml)
   - Remote server setup (change localhost to server IP)
6. API Reference (POST /notify with full schema)
7. Sound Reference (table of 6 sounds)
8. Customization (port, sounds, adding new AI sources)
9. Troubleshooting (common issues)
10. License

Both English and Chinese (中文) sections.

**Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add comprehensive README with setup instructions"
```

---

### Task 7: Create GitHub Repository and Push

**Step 1: Create GitHub repo**

```bash
gh repo create ai-sound-notify --public --description "Sound notification system for AI coding agents (Claude Code, Gemini CLI, Codex CLI)" --source .
```

**Step 2: Push all commits**

```bash
git push -u origin main
```

**Step 3: Verify**

```bash
gh repo view --web
```
