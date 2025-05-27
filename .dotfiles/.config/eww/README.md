# Eww Config

ElKowar's Wacky Widgets is a widget system made in rust. Widgets are defined using a language called `yuck`. The official documentation for Eww is [here](https://elkowar.github.io/eww/eww.html).

## Volume and Brightness (Device) Popups

Why: The device popups intend to notify user during volume and brightness changes.

What: Consists of two widgets: brightness and volume. Their windows only appear during brightness/volume changes

File architecture:
```
my-awesome-app/
├── scripts/
│   ├── brightness.sh   # Subscribe to brightness changes and update eww variable
│   ├── volume.sh       # Subscribe to volume changes and update eww variable
├── eww.yuck            # Defines two windows: brightness-popup and volume-popup
├── eww.css             # Defines styles
├── README.md           # Current document
```

**Dependencies**:
* `pulseaudio` or `pipewire`: these are sound servers. These should aready exist in your system since a sound server is mandatory for audio. These two sound servers provide a `pactl` command to control volume, used in `volume-subscriber.sh`. 

* `inotify-wait`: a tool that subscribes to a file and notify changes. Used by the brightness widget because brightness can be read by or written to the file `/sys/class/backlight/$BACKLIGHT_DIR/brightness`, where `$BACKLIGHT_DIR` depends on your system.

**Possible Changes**:
* The two shell scripts may require modification depending on your system. They should detect volume and brightness changes to update the eww variables with the syntax:
```bash
eww -c <config-file-dir> update volume-changed=true
eww -c <config-file-dir> update brightness-changed=true 
```

* The commands above run `eww` - this assumes `eww` is installed in the same directory as the scripts. Use the actual location of the `eww` binary should be used instead.