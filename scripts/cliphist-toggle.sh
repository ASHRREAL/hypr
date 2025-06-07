#!/bin/bash

# Check if wofi is already running (to toggle it)
if pgrep -x wofi >/dev/null; then
  pkill -x wofi
else
  # Show clipboard history via cliphist and wofi
  selected=$(cliphist list | wofi --dmenu -p "Clipboard:")

  # If something was selected, decode and copy it back to clipboard
  [ -n "$selected" ] && cliphist decode <<<"$selected" | wl-copy
fi
