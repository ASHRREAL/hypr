#!/bin/bash

if pgrep -x wofi >/dev/null; then
  # Simulate pressing Escape to close wofi-calc gracefully
  ydotool key 1
  sleep 0.1 # Small delay to ensure it closes
else
  # Launch wofi-calc if not running
  wofi-calc &
fi
