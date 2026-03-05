#!/bin/bash
# AI Sound Notify - Generic notification helper
# Usage: ./notify.sh <source> <event> [message]
# Example: ./notify.sh claude-code task_complete "Build finished"
#
# Environment variables:
#   AI_NOTIFY_SERVER - Server URL (default: http://localhost:9800)

SERVER="${AI_NOTIFY_SERVER:-http://localhost:9800}"
SOURCE="${1:?Usage: notify.sh <source> <event> [message]}"
EVENT="${2:?Usage: notify.sh <source> <event> [message]}"
MESSAGE="${3:-}"

curl -s -X POST "$SERVER/notify" \
  -H 'Content-Type: application/json' \
  -d "{\"source\":\"$SOURCE\",\"event\":\"$EVENT\",\"message\":\"$MESSAGE\"}"
