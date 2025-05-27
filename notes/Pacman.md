# Arch Pacman

This section is for understanding the arch package manager.

Arch Official Wiki for Pacman: https://wiki.archlinux.org/title/Pacman#Querying_package_databases

There are three "databases" that `pacman` deals with:

1. **Local database** - local database storing the list of all installed packages
2. **Sync database** - remote database storing the list of all possible packages in online repositories defined in `/etc/pacman.conf`. Each repo (core, extra, community ...) has its own database

   - `/var/lib/pacman/sync/core.db`
   - `/var/lib/pacman/sync/extra.db`

3. **Files database** - A database that enables **file searching** of all packages (local and remote).
   - This feature is not enabled by default. To download it, run `pacman -Fy`

The most common `pacman` commands 1:

| Command                    | Meaning in Terms of Database                                                                                      |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| `pacman -Syu`              | Sync local package database with remote (`-y`), then upgrade installed packages (`-u`) by comparing with sync DBs |
| `pacman -Ss <pkg>`         | Search sync database for a package                                                                                |
| `pacman -Si <pkg>`         | Show detailed info from sync database                                                                             |
| `pacman -Qs <pkg>`         | Search locally installed packages                                                                                 |
| `pacman -Qi <pkg>`         | Show detailed info from local database                                                                            |
| `pacman -Ql <pkg>`         | List files installed by a package (local DB)                                                                      |
| `pacman -Qo /path/to/file` | Query local DB: "Which installed package owns this file?"                                                         |
| `pacman -F /path/to/file`  | Query sync **files database**: "Which available package would install this file?"                                 |
