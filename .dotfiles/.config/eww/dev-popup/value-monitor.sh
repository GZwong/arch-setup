#!/bin/bash
# Combined monitor script for brightness, temperature, and volume changes
# ~/.config/eww/scripts/value-monitor.sh

# Define the full path to your Eww config directory
EWW_PATH="$HOME/.local/bin/eww"
EWW_CONFIG="$HOME/.config/eww/dev-popup"
BACKLIGHT_DIR="intel_backlight"

# Function to update eww variables
update_eww() {
    $EWW_PATH -c "$EWW_CONFIG" update "$@"
}

# Function to hide all popups
hide_all_popups() {
    update_eww brightness-changed=false volume-changed=false temperature-changed=false
}

# Function to show popup and hide others
show_popup() {
    local popup_type="$1"
    case "$popup_type" in
        "brightness")
            update_eww brightness-changed=true volume-changed=false temperature-changed=false
            ;;
        "volume")
            update_eww volume-changed=true brightness-changed=false temperature-changed=false
            ;;
        "temperature")
            update_eww temperature-changed=true brightness-changed=false volume-changed=false
            ;;
    esac
    
    # Hide after 3 seconds
    (sleep 3 && hide_all_popups) &
}

# Brightness monitor function
monitor_brightness() {
    local last_event_time=0
    local debounce_interval=1
    
    while true; do
        # Wait for brightness change
        inotifywait -e modify /sys/class/backlight/$BACKLIGHT_DIR/brightness 2>/dev/null
        
        local current_time=$(date +%s)
        if (( current_time - last_event_time > debounce_interval )); then
            show_popup "brightness"
            last_event_time=$current_time
        fi
    done
}

# Temperature monitor function
monitor_temperature() {
    local prev_temp=""
    
    while true; do
        local current_temp=$(hyprctl hyprsunset temperature 2>/dev/null)
        
        if [[ -n "$prev_temp" && "$current_temp" != "$prev_temp" ]]; then
            show_popup "temperature"
        fi
        
        prev_temp="$current_temp"
        sleep 0.5
    done
}

# Read volume function
read_current_volume() {

    # 1. Use pulse audio to get the default speaker volume (pactl)
    # 2. Use `awk`` to get the print the fifth field of the first line (NR == 1), which is the volume percentage (e.g. 15%)
    # 3. Use `tr` to delete the percentage character
    local current_volume=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | awk 'NR == 1 {print $5}' | tr -d '%')

    # Output
    echo "$current_volume"
}

# Volume monitor function
monitor_volume() {
    local last_volume=$(read_current_volume)
    
    while true; do
        local current_volume=$(read_current_volume)

        if [[ -n "$current_volume" && "$current_volume" != "$last_volume" ]]; then
            show_popup "volume"
            last_volume="$current_volume"
        fi
        
        sleep 0.3
    done
}

# Cleanup function
cleanup() {
    echo "Stopping all monitors..."
    hide_all_popups
    kill $(jobs -p) 2>/dev/null
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Start all monitors in the background
echo "Starting combined monitor script..."
echo "Monitoring brightness, temperature, and volume changes..."

monitor_brightness &
monitor_temperature &
monitor_volume &

# Wait for all background processes
wait