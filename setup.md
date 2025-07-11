# Arch Linux Setup

This setup has the following stack:

- **Hyprland** - as a window manager
- SDDM (Simple Desktop Display Manger) to provide a login GUI
  - The desktops exist under `/usr/share/wayland-sessions/` as `.desktop` files.
- Waybar - Status bar
- thunar - minimalistic file manager
- alacritty - terminal to be used in hyprland
- zsh - An alternative of the default `bash` shell offering advanced features, customizations and community support.

# Functionalities

Some functionalities, like audio, brightness control, function keys, do not
work out of the box. This section outlines the steps to fix them.

## Audio

Refer to [Arch Sound System Guide](https://wiki.archlinux.org/title/Sound_system)

Audio consists of interfacing layers, starting from the hardware level to the
application level. Starting from the lowest level:

### 1. Drivers and Interface

ALSA (Advanced Linux Sound Architecture) is the default Linux kernel component
providing device drivers and lowest-level support for audio hardware.

Download utility functionality for ALSA:

```bash
sudo pacman -S alsa-utils
```

### 2. Sound server

Pipewire is used as a dound server.
It is superior compared to older alternatives such as pulseaudio.
To download:

```bash
sudo pacman -S pipewire pipewire-audio pipewire-pulse pipewire-alsa wireplumber
systemctl --user enable pipewire pipewire-pulse wireplumber
systemctl --user start pipewire pipewire-pulse wireplumber
```

Pipewire includes wireplumber as a session manager.

### Additional Firmwares

If audio still does not work after both steps above, download the following
firmware:

```bash
sudo pacman -S sof-firmware linux-firmware
```

You can test if your audio system is configured correctly by running the
command below. You should be able to hear sounds from your speaker.

```bash
speaker-test -c 2
```

If audio is still not configured correctly, look at the GUI section below as
it is the simplest way to configure audio.

### 3. GUI (Recomended + Optional)

A GUI interface will be the easiest way to manage audio settings.

Pavucontrol is the simplest GUI interface.

```bash
sudo pacman -S pavucontrol
```

## Video

Webcams should work right out of the box.

### v412 (Video 4 Linux 2)

v4l2 is the official Linux kernel API to interact with audio devices.
`v4l-utils` provide a set of tools to interact with video devices. To install:

```bash
sudo pacman -S v4l-utils
```

This library provide programs such as:

```bash
v4l2-ctl --list-devices  # List video devices
```

### Video GUI

Camera apps just refer to applications that show video output on your display.
Below are a few options:

#### MPV

`mpv` is a lightweight video tool that allow playback, subtitles and more.

- To download: `sudo pacman -S mpv`
- Webcam preview: `mpv av://v4l2:/dev/video0`

Here is the explanation behind the command

```
mpv av://v4l2:/dev/video0
    │   │     └─ Path to webcam device
    │   └──────── Input format backend (FFmpeg: "av" = libavdevice)
    └──────────── Protocol prefix for ffmpeg-compatible input
```

_Running the above for my case uses a frame rate ot 5.0 fps. This can be
changed via additional arguments, such as:_

```bash
mpv av://v4l2:/dev/video0 --demuxer-lavf-o=video_size=1920x1080,framerate=30,input_format=mjpeg
```

## Function keys

The function keys like changing volume and brightness do not work by default.

### Brightness control

For a detailed guide: https://wiki.archlinux.org/title/Backlight

The brightness settings are stored in the directory `/sys/<class>/backlight`. _Class_ can differ based on systems. For my laptop (an Intel system) it is _intel_backlight_.

The folder structure of `/sys/<class>/backlight` is:

```
-- actual_brightness
-- bl_power
-- brightness
-- device
-- max_brightness
-- power
-- scale
-- subsystem
-- type
-- uevent
```

The max brightness is stored in `max_brightness` and the current brightness is stored in `brightness`. Observe their value using `cat`:

```bash
cat max_brightness
cat brightness
```

If we are a root user, the brightness can be changed trivially:

```bash
echo 200 > ~/sys/<class>/backlight/brightness
```

However, as a normal user, permission to do this is denied. We can either change the permission or install a software to do this:

#### brightnessctl

```bash
sudo pacman -S brightnessctl
brightnesctl set 200   # Set brightness to 200 units
brightnessctl set 25%  # Set brightness to 25% of max
```

## External Monitors

External monitors work by default but their size, position and scale may not be desired. This is controlled by the window manager. For Hyprland, monitor behaviour is defined in `hyprland.conf`:

```bash
# Convention
monitor = [display], [resolution], [position], [scale]

# Example
monitor = eDP-1, 2880x1440, 0x0, 2  # eDP-1 refers to integrated monitor
monitor = DP-9, 1440x0, 0.0, 1   # To the right of eDP-1 (2880/2 = 1440 (see below))
```

**Gotcha**
Monitor position is affected by scale!

The position is calculated with the scaled (and transformed) resolution, meaning if you want your 4K monitor with scale 2 to the left of your 1080p one,
you’d use the position 1920x0 for the second screen (3840 / 2). If the monitor is also rotated 90 degrees (vertical), you’d use 1080x0.

## Lid Open/Close Behaviour

The config for this behaviour is stored in `/etc/systemd/logind.cong`.
This configuration is entirely commented.

```conf
#HandleLidSwitch=suspend
#HandleLidSwitchExternalPower=suspend
#HandleLidSwitchDocked=ignore
#HandleSecureAttentionKey=secure-attention-key
#PowerKeyIgnoreInhibited=no
#SuspendKeyIgnoreInhibited=no
#HibernateKeyIgnoreInhibited=no
#LidSwitchIgnoreInhibited=yes
```

If these options are not configured, systemd will use its defaults: HandlePowerKey=poweroff, HandleSuspendKey=suspend, HandleHibernateKey=hibernate, and HandleLidSwitch=suspend.

**Turn off laptop display when lid is closed**

Source: https://wiki.hyprland.org/Configuring/Binds/#switches

By default, when a laptop is connected to an external display and its lid is closed, the integrated display will still be on. This is not a behaviour controlled by Arch, but rather the compositor.

For Hyprland, add the following into Hyprland config:

```bash
bindl = , switch:on:<switch name>, exec, hyprctl keyword monitor "eDP-1, disable"
bindl = , switch:off:<switch name>, exec, hyprctl keyword monitor "eDP-1, preferred, 0x0, 2"
```

- `switch name` is a device switch that can be found with the command `hyprctl devices`. It should be called something akin to "Lid Switch"
- the monitor keyword follows the convention `monitor = [display], [resolution], [position], [scale]`

<br>

# Applications

Arch is a minimal Linux distro. Here are some important applications and
nice-to-haves.

## Notification daemon

A software that let apps publish notifications on the D-bus (desktop bus).

There are several options:

- `mako`: lightweight, modern, good integration with wayland
- `swaync`: A heavier notification daemon, with features like notification history

## Status Bar

Waybar is a status bar for wayland. To run waybar upon hyprland startup, add
the following line to `~/.config/hypr/hyprland.config`:

```bash
exec once = waybar
```

The default waybar has audio, wifi, cpu usage, ram usage etc. The configuration are stored in two per-user files:

- `~/.config/waybar/config.jsonc` - What the waybar shows
- `~/.config/waybar/style.css` - How the waybar is styled

### Small fixes

Some functionalities of the waybar do not work out of the box

- `custom/power` - this is the button that trigger a menu to shutdown, hibernate, etc. This requires populating `menu-action` in the config properly.
- Input devices and keyboard state - need to add user to input group with

```bash
sudo usermod -aG input $USER
```

- `power-profiles-daemon` - **Power Profile Daemon** is a daemon that monitors the current power mode (performance, balanced or battery-saving)

```bash
sudo pacman -S power-profiles-daemon
sudo systemctl enable power-profiles-daemon
sudo systemctl start power-profiles-daemon
```

- `media` - The JSON config below for a custom spotify module shows a spotify icon on the waybar with its tooltip shwoing the artist and media title. Content from the `exec` command gets routed to the `{}` placeholder.
  _The `2>/dev/null` routes standard error to a null device, essentially supressing erorr messages_.

```json
  "custom/spotify": {
      // "format": " {}",  // Uncomment if you want to show artist name and media title
      "format": "",
      "tooltip": true,
      "tooltip-format": " {}",
      "max-length": 40,
      "escape": true,
      "exec": "playerctl metadata --format '{{artist}} - {{title}}' --player=spotify 2>/dev/null",
      "on-click": "playerctl play-pause --player=spotify",
      "on-scroll-up": "playerctl next --player=spotify",
      "on-scroll-down": "playerctl previous --player=spotify"
  }
```

- Waybar also has a `mediaplayer.py` script found on their GitHub that can works seamlessly with waybar. It offers automatic detection of when the player opens/close, but requires the gObject-Introspection library installed with: `sudo pacman -S python-gobject`.

- `keyboard-state` shows the state of **caps-lock** and **nums-lock**. By default, it can be unresponsive, showing the wrong state if you lock and unlock quickly. It probably iterates through all possible devices on an event loop. We can increase its responsiveness by specifying the device. List the available devices with: `libinput list-devices` and enter the path of the device:

```json
"keyboard-state": {
  "device-path": "/dev/input/event11" // Path to the keyboard device
}
```

- An alternative to `keyboard-state` for laptops that have an LED to show caps-lock is to use the solution defined here: https://github.com/Alexays/Waybar/issues/2215 though doesn't seem to work correctly for me

### Development Tip

Reload the waybar with `pkill waybar && nohup waybar &` where `nohup`(no hang up) detaches the process from the current terminal session.

## Authentication agent

Some actions require authentication, such as mounting drives, changing network s
ettings, or rebooting via a GUI.

The recommended authentication for Hyprland is `hyprpolkitagent`, which can be
easily installed via package manager:

```bash
sudo pacman -S hyprpolkitagent
```

## App Launcher

I have used `wofi` as the main application launcher. See
https://man.archlinux.org/man/wofi.1 for more information. Download with:

```bash
sudo pacman -S wofi
```

There are three configuration files:

1. `$XDG_CONFIG_HOME/wofi/config` - Control how various run config, like run mode (e.g. show desktop apps or show commands), whether to show images beside apps, where to place the window, etc.
2. `$XDG_CONFIG_HOME/wofi/style.css` - Control look and feel
3. `$XDG_CACHE_HOME/wal/colors` - Colors file, default to the pywall cache.

To run wofi, you need to supply a mode. A list of modes can be seen [here](https://man.archlinux.org/man/wofi.7.en).

1. `run` - searches $PATH for executables and allows them to be run by selecting them.
2. `drun` - searches $XDG_DATA_HOME/applications and $XDG_DATA_DIRS/applications for desktop files and allows them to be run by selecting them.
3. `dmenu` - reads from stdin and displays options which when selected will be output to stdout.

For example, to show desktop files, run

```bash
wofi --show drun
```

I have added the command above to a hyprland shortcut:

```bash
bind = SUPER, ENTER, exec, wofi --show drun
```

## Snipping Tool

Hyprshot is the snipping tool for Hyprland.

Install with `yay -S hyprshot`.

See options with `hyprshot -h`.

## Display Manager

A Display Manager like SDDM serves as a graphical login interface for the
system. It is responsible for handling user authentication, starting your
session and launching the appropriate desktop environment/window manager.

I have used **SDDM** (Simple Desktop Display Manager)

## UWSM (Universal Wayland Session Manager)

Documentation of UWSM on the [Hyprland Wiki](https://wiki.hyprland.org/Useful-Utilities/Systemd-start/).

Arch is a systemd Linux distro. We can use UWSM to launch Hyprland as a systemd service to take advantage of the robust session management provided by systemd, including:

- Setting environment variables
- XDG (Cross Desktop Group) autostart
- Bi-directional binding with login session
- Clean shutdown

To download from the official repo:

```bash
pacman -S uwsm
```

To launch Hypprland with uwsm, add the following to the `~/.bash_profile`:

```bash
if uwsm check may-start && uwsm select; then
	exec uwsm start default
fi
```

This will (automatically?) create a `hyprland-uwsm.desktop` file under `/usr/share/wayland-sessions/` as an additional session. If `sddm` is installed, this will automatically show up as one of the possible sessions to log into. if `hyprland-uwsm.desktop` does not exist, create the file and paste this content:

```
[Desktop Entry]
Name=Hyprland (uwsm-managed)
Comment=An intelligent dynamic tiling Wayland compositor
Exec=uwsm start -- hyprland.desktop
DesktopNames=Hyprland
Type=Application
```

Todo: Currently applications like waybar and swaync and ran under the wayland compositor. With UWSM, we can run it is as a systemd service/unit to take advantage of the facilities provided by systemd.

# Shortcuts

Some keyboard <Ctrl> shortcuts are interpreted by the command shell, which runs inside the terminal emulation. Usually this will be bash.
E.g. <ctrl>c will abort an operation in bash. Therefore <Ctrl><Shift>c has to be used for copying.
The most common <Ctrl><Shift> key combinations will be <Ctrl><Shift>c, <Ctrl><Shift>v and <Ctrl><Shift>a.
The additional <Shift> key is what makes sure that the keyboard shortcut will be interpreted by the terminal window, not by the shell, which runs inside the terminal emulation.

# Language Support

This is the official Arch wiki on adding support for simplified chinese, but the concept can be applied to other locales/languages as well: https://wiki.archlinux.org/title/Localization/Simplified_Chinese

### Install chinese locale

_This step can be skipped if you only care about viewing a new language in a program that can specify its own encoding, such as Firefox_

Setting up a locale refers to setting up:

- Character Encoding - how binary data are interpreted as text, ltypically `UTF-8`.
- Language - Once the character is decoded, it goes through a translation layer depending on the selected language. One of its effects is **system messages**, like `error: file not found`. It does this by looking up a map defined in a `.mo` file of the chosen language.
- Number/data/currency formats.

Modify `/etc/locale.gen` (require sudo) to set the locales, by uncommenting the locale you wish to add. It is recommended to use the locale with UTF-8 encoding.

After changing `/etc/locale.gen`, execute the following to install the locale

```bash
sudo locale-gen
```

This will install the selected locales. You may use `locale` to view the currently used locale(s), and `locale -a` to view the currently available locales.

### Installing fonts

With the encoding setup, a program can crunch those bytes into the appropriate character (for `UTF-8`, decoding bytes outputs **Unicode code points** like `U+4F60`). We still need to install the font as a visual representation of those characters. A font provides **glyps** that define a vector or bitmap to draw out characters.

- If no font supports the glyph → you get a box (□)

Some symbols may not be supported so install these fonts:

```bash
sudo pacman -S noto-fonts-emoji ttf-font-awesome ttf-nerd-fonts-symbols
```

A common chinese font is `noto-fonts-cjk` whiich includes chinese, japanese and korean, hence the name cjk.

```bash
sudo pacman -S noto-fonts-cjk`
```

Refer below to see where fonts are installed.

## Media Player

The main tool to interact with media player on the command line is `playerctl` (player control).

```bash
playerctl --player=spotify play-pause  # Toggle play or pause on spotify
playerctl next      # Skip to next song on currently selected player
playerctl previous  # Skip to the previous song on the currently selected player
playerctl metadata artist  # Get the current artist name
playerctl metadata title   # Title of current media
```

In fact, this works with any player that implements the MPRIS (Media Player Remote Interfacing Specification) interface.

## Speech Dispatcher

The Arch Linux wiki page is an excellent resource for [speech dispatcher and synthesizers](https://wiki.archlinux.org/title/Speech_dispatcher).

Speech Dispatcher is a device independent layer for speech synthesis that provides a common easy to use interface for both client applications (programs that want to speak) and for software synthesizers (programs actually able to convert text to speech)."

You will encounter an error message of missing speech dispatcher when you visit websites that support text to speech.

Installing speech dispatcher

```bash
sudo pacman -S speech-dispatcher
```

Installing a speech synthesizer

```bash

```

# Customizations

Check hyprland ecosystem: https://wiki.hyprland.org/Hypr-Ecosystem/

- Hyprpaper - wallpaper utility for hyprland
- Hyprpicker - amazing color picker for `wlroots` compositors
- Eww - create custom widgets. See [official documentation](https://elkowar.github.io/eww/eww.html)
  for installation details, see community examples for implementation details.

  - Eww is a rust library so we need to install the toolkit to compile it.
    The command below installs `rustc` (compiler), `rustup` (updater) and
    `cargo` (package manager, analagous to pip on python) in the directory
    `$HOME/.cargo/bin`.

    ```bash
    curl https://sh.rustup.rs -sSf | sh
    ```

    Then to activate the environment, simply run the proovided script at
    `$HOME/.cargo/env` which adds the toolkits to the path.

  - Building eww binary for wayland:

    ```bash
    git clone https://github.com/elkowar/eww
    cd eww
    cargo build --release --no-default-features --features=wayland

    # Make the binary executable
    cd target/release
    chmod +x ./eww
    ```

  - Running the eww daemon:
    ```bash
    ./eww daemon  # Start the eww daemon
    ./eww open <window_name>  # Open a window
    ```

- `zsh` and `oh-my-zsh`

  - `zsh` is an alternative shell for `bash`.

  - To download: `sudo pacman -S zsh zsh-completions`

  - Change `zsh` to the default shell: `chsh -s /bin/zsh`

  - Install `oh-my-zsh`, a framework for managing `zsh` configuration:

    ```
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    ```

  - Used the popular powerlevel-10k zsh configuration. See the [configuration file](.dotfiles/.zshrc).

- `kanshi` - Used to set up default display profiles (e.g. setup a home profile whenever laptop is connected to external display to only use external display). The configuration file is located [here](.dotfiles/.config/kanshi/config).

- `hyprexpo` - Plugin that enables a view of all workspaces, similar to Mac OS Mission Control.
