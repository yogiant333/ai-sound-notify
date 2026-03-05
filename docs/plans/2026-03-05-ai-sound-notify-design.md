# AI Sound Notify - Design Document

## Overview

A lightweight notification system that plays distinct sounds in a web browser when AI coding agents (Claude Code, Gemini CLI, Codex CLI) complete tasks or need user input. Designed for users managing multiple remote SSH sessions via tools like Nexterm.

## Architecture

```
Claude Code / Gemini CLI / Codex CLI
         │ HTTP POST /notify
         ▼
  Node.js Server (port 9800)
  - Express (HTTP API)
  - WebSocket Server (ws)
         │ WebSocket push
         ▼
  Browser Notification Page
  - Web Audio API synthesized sounds
  - 6 distinct sound combinations
  - Notification history
```

## API

```
POST /notify
{
  "source": "claude-code" | "gemini" | "codex",
  "event": "task_complete" | "need_input",
  "message": "optional description",
  "session_id": "optional session id"
}
```

## Sound Design

Using Web Audio API, no audio files needed:
- task_complete: single rising tone (different frequency per AI)
- need_input: double urgent tone (different frequency per AI)

| Source | task_complete freq | need_input freq |
|--------|-------------------|-----------------|
| Claude Code | 880 Hz (high) | 880 Hz (high) |
| Gemini | 660 Hz (mid) | 660 Hz (mid) |
| Codex | 440 Hz (low) | 440 Hz (low) |

## Hook Integration

### Claude Code (~/.claude/settings.json)
- Stop event -> task_complete
- Notification (idle_prompt, permission_prompt) -> need_input

### Gemini CLI (~/.gemini/settings.json)
- AfterAgent event -> task_complete
- Notification event -> need_input

### Codex CLI (~/.codex/config.toml)
- notify config -> task_complete (agent-turn-complete)
- approval-requested: TUI only (no external hook support yet)

## Project Structure

```
ai-sound-notify/
├── server/
│   ├── index.js
│   └── package.json
├── web/
│   └── index.html
├── scripts/
│   ├── notify.sh
│   └── test-notify.sh
├── configs/
│   ├── claude-code.json
│   ├── gemini.json
│   └── codex.toml
├── README.md
├── LICENSE
└── .gitignore
```

## Dependencies

- express
- ws
