#!/bin/bash

# Define the full path to your Eww config directory
EWW_PATH="$HOME/.local/bin/eww"
EWW_CONFIG="$HOME/.config/eww/dev-popup"

last_volume=""

while true; do
  # Get current volume of the default sink ($5 points to front left)
  current_volume=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | tr -d '%')
  
  if [[ "$current_volume" != "$last_volume" ]]; then
    $EWW_PATH -c "$EWW_CONFIG" update volume-changed=true

    # Hide the brightness widget since they occupy the same space
    $EWW_PATH -c $EWW_CONFIG update brightness-changed=false

    sleep 3
    $EWW_PATH -c "$EWW_CONFIG" update volume-changed=false
    last_volume="$current_volume"
  fi
  
  sleep 0.3
done

