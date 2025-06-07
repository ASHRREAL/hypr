#!/bin/bash

LOCKFILE="/tmp/wofi-calc.lock"

# If the lock exists, this means toggle is OFF — just quit silently
if [[ -f "$LOCKFILE" ]]; then
    rm "$LOCKFILE"
    exit
fi

# Create lock to prevent recursive spawn
touch "$LOCKFILE"

# Get the expression from the user
expr=$(wofi --dmenu --prompt "Calc")
if [[ -z "$expr" ]]; then
    rm "$LOCKFILE"
    exit
fi

# Evaluate and show result
echo "$expr = $(echo "$expr" | bc -l)" | wofi --dmenu

# After the second wofi, clean up
rm "$LOCKFILE"

