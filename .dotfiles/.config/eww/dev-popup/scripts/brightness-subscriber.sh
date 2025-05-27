#!/bin/bash

# Define the full path to your Eww config directory
EWW_PATH="$HOME/.local/bin/eww"
EWW_CONFIG="$HOME/.config/eww/dev-popup"
BACKLIGHT_DIR="intel_backlight"

# Initialize the last event timestamp
last_event_time=0
debounce_interval=1  # NOTE: Float not supported (need bc) Time in seconds to debounce the brightness change events

# Listener for brightness change events using brightnessctl
# This uses inotifywait to monitor the brightness level file for changes.
while true; do
  # Wait for a change in the brightness (require inotify-wait tools)
  inotifywait -e modify /sys/class/backlight/$BACKLIGHT_DIR/brightness

  # Get the current timestamp
  current_time=$(date +%s)

  # Check if enough time has passed since the last event to debounce
  if (( current_time - last_event_time > debounce_interval )); then

    # Update the Eww widget to indicate brightness has changed
    $EWW_PATH -c $EWW_CONFIG update brightness-changed=true

    # Hide the volume widget since they occupy the same space
    $EWW_PATH -c $EWW_CONFIG update volume-changed=false

    # Update last event timestamp
    last_event_time=$current_time

    # Wait for a bit before hiding the widget
    sleep 3

    # Close the widget
    $EWW_PATH -c $EWW_CONFIG update brightness-changed=false
  fi
done
