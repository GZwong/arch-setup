# OneDrive Setup (Arch)

`rclone` is the tool I use to configure OneDrive on Arch Linux.
It works with many other cloud providers as well.

To download `rclone`:

```bash
sudo pacman -S rclone
```

This web page offers a great tutorial on how to set this up:
https://itsfoss.com/use-onedrive-linux-rclone/

We can use OneDrive in two modes:

## 1. Mount

Mounting the remote named `onedrive` to a local directory named `OneDrive`:

```bash
rclone mount --vfs-cache-mode=writes onedrive: ~/OneDrive
```

This merely mounts the files stored in the remote to be accessible via the file
system hierarchy. The files themselves are not actually available locally.

To perform this mount during startup, a `systemd` service can be used.

## 2. Sync

The **sync** mode is the one I use where it syncs a source directory to a
destination directory. (The destination will be forced to match the source)

To sync a remote named `onedrive` to a local directory at `~/OneDrive`:

```bash
rclone sync onedrive: ~/OneDrive
```

This will match the local folder **exactly** to the remote - any changes you
have made locally will be overwritten.

To upload updates available locally to the remote, just switch the `sync`
command:

```bash
rclone sync ~/OneDrive onedrive:
```

To sync during startup, use a user-level `systemd` service and timer.

**Service:**

```bash
# ~/.config/systemd/user/rclone-onedrive-sync.service
#!/bin/bash

[Unit]
Description=Sync OneDrive to local folder via rclone
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/rclone bisync /home/gaizhe/OneDrive onedrive: \
    --log-file=/home/gaizhe/.cache/rclone/onedrive-sync.log \
    --log-level=INFO
Environment=RCLONE_CONFIG=/home/gaizhe/.config/rclone/rclone.conf

[Install]
WantedBy=default.target
```

**Timer:** (Read from remote every hour)

```bash
[Unit]
Description=Run rclone sync every hour

[Timer]
OnCalendar=hourly
Persistent=true

[Install]
WantedBy=timers.target
```

Note:

- `OnCalendar=hourly` means the service will be run everytime the clock hits 00
- `Persistent` tells systemd to catch up on missed job when the system was off or sleeping when the timer was scheduled.

To enable them:

```bash
# Reload daemon
systemctl --user daemon-reload

# Enable targets
systemctl --user enable rclone-onedrive-sync.service
systemctl --user enable rclone-onedrive-sync-timer
```

## 3. Bisync

_Note: The `rclone bisync` command is still in BETA and should not be used in production._

`rclone bisync` allows bi-directional sync, where the source of truth is maintained based on the latest modification time by defauly.

The current setup uses `bisync` instead of `sync`. These are available in [`.config/systemd/user`](.dotfiles/.config/systemd/).

A desktop entry for `bisync` has also been implemented [here](.dotfiles/.local/share/applications/rclone-bisync.desktop). This desktop entry can be called in `wofi` or equivalent app
launchers to manually sync for changes.
