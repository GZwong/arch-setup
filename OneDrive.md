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

The **sync** mode is the one I use where it syncs the remote directory to a
local directory.

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

To sync during startup, use a user-level `systemd` service and timer. These
are available in `.config/systemd/user`.

To enable them:

```bash
# Reload daemon
systemctl --user daemon-reload

# Enable targets
systemctl --user enable rclone-onedrive-sync.service
systemctl --user enable rclone-onedrive-sync-timer
```

For more advanced usage, use `bisync`.
