# Arch Setup

This repository stores documentation and files needed to setup Arch Linux to
my preferred configuration.

```
arch-setup
│
├─ 📁 .dotfiles
│  ├── 📁 .config
│
├─ 📁 notes
│
└─ README.md
```

- `.dotfiles/` contain the configuration files for applications. The
  instruction for generating these locally using `stow can be read beloow.
- `notes/` contain markdown fiiles that outlines my learnings about Linux.

# Generate dotfiles

I use `stow` as a symlink farm manager to automate the creation of symlinks in
the `$XDG_HOME_CONFIG` directory that points to the actual contents within
`.dotfiles`. This centralizes the management of .dotfiles using `git`.

At the root of the repository, run the following command:

```bash
stow .dotfiles  # specify the package as .dotfiles
```
