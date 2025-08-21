#!/bin/bash

notify-send "OneDrive Sync" "Starting rclone bisync..."
rclone bisync ~/OneDrive onedrive: \
  --exclude "Personal Vault/**" \
  --verbose \
  --log-file ~/.cache/rclone/onedrive-sync.log

if [ $? -eq 0 ]; then
  notify-send "OneDrive Sync" "Sync complete ✅"
else
  notify-send "OneDrive Sync" "Sync failed ❌ — check logs"
fi
