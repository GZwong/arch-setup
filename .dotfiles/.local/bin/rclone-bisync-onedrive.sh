#!/bin/bash

notify-send "OneDrive Sync" "Starting rclone bisync..."
rclone bisync ~/OneDrive onedrive: \
  --log-file ~/.local/share/rclone-bisync.log \
  --log-level INFO

if [ $? -eq 0 ]; then
  notify-send "OneDrive Sync" "Sync complete ✅"
else
  notify-send "OneDrive Sync" "Sync failed ❌ — check logs"
fi
