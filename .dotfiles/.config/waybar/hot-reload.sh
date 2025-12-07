#!/usr/bin/env bash

CONFIG="$HOME/.config/waybar/config.jsonc"
STYLE="$HOME/.config/waybar/style.css"

# Use jsonc OR json depending on your setup
# Update the paths above as needed

echo "Watching Waybar files for changes..."
echo "$CONFIG"
echo "$STYLE"

while inotifywait -e close_write "$CONFIG" "$STYLE"; do
    echo "Reloading Waybar..."
    pkill -SIGUSR2 waybar
done
