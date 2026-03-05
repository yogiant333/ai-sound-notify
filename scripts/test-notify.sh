#!/bin/bash
# AI Sound Notify - Test all 6 notification types
# Sends each notification with a 2s delay between them

SERVER="${AI_NOTIFY_SERVER:-http://localhost:9800}"

echo "Testing all 6 notification types..."
echo "Server: $SERVER"
echo ""

for source in claude-code gemini codex; do
  for event in task_complete need_input; do
    echo "  -> $source / $event"
    curl -s -X POST "$SERVER/notify" \
      -H 'Content-Type: application/json' \
      -d "{\"source\":\"$source\",\"event\":\"$event\",\"message\":\"Test: $source $event\"}"
    echo ""
    sleep 2
  done
done

echo ""
echo "Done! Check your browser for notifications."
