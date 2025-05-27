# Fonts

## Font Directory in Linux

| Directory                              | Purpose                                                      | Notes                                                                |
| -------------------------------------- | ------------------------------------------------------------ | -------------------------------------------------------------------- |
| `/usr/share/fonts/`                    | **System-wide fonts** installed via packages (e.g. `pacman`) | Managed by the system, available to all users                        |
| `/usr/local/share/fonts/`              | **System-wide custom fonts** installed manually              | Not commonly used, but respected by Fontconfig                       |
| `~/.local/share/fonts/` or `~/.fonts/` | **User-only fonts** (for a single user)                      | You place fonts here if you want to install them without root access |

Under the `font/` directory lies more directory - one directory for each font family. Each family contains variations like bold, italic, thin, semibold etc.

Use this command to see the list of installed fonts:

```bash
fc-list
fc-list | wc -l   # How many fonts are installed
fc-list : family  # List font families
```

The output will look like:

```bash
/usr/share/fonts/TTF/JetBrainsMonoNLNerdFont-ExtraBold.ttf: JetBrainsMonoNL Nerd Font,JetBrainsMonoNL NF,JetBrainsMonoNL NF ExtraBold:style=ExtraBold,Regular
/usr/share/fonts/TTF/JetBrainsMonoNerdFontMono-ExtraBoldItalic.ttf: JetBrainsMono Nerd Font Mono,JetBrainsMono NFM,JetBrainsMono NFM ExtraBold:style=ExtraBold Italic,Italic
```

where it shows the **file name** for the font before the `:`, and the font **internal name** after. Use the internal name when configuring fonts, say in VS code..

## Font config

In most Linux distributions, fonts are managed by the `fontconfig` program. `Fontconfig` is **not a font renderer** but can perform:

- Discover available fonts on your system
- Match fonts to user/application requests (like "sans-serif" or "monospace")
- Handle font substitutions, fallbacks, and language/script preferences
- Configure font rendering options (antialiasing, hinting, etc.)
- Cache font metadata for performance

_Note: FreeType renders the font glyph and Cairo draws them (depends on what renderer and display protocol)_

Relevant files/directories:

- `/etc/fonts/fonts.conf` - a **file** that handles font categories (see below) by pointing to the config location.
- `/etc/fonts/conf.d/` - a **directory** containing files that are **symbolic links** to `.conf` files that control, anti-aliasing, fallbacks etc. The actual files are located under `/usr/share/fontconfig/conf.default/` or `/usr/share/fontconfig/conf.available/`
  - The names of each files follow the convention `<number>-<name>.conf`, such as `10-hinting-alight.conf` and `40-nonlatin.conf`.
  - The numbers are used as prefixes because Fontconfig processes these file in lexical (numerical) order. The ones with lower numbers load the core settings whilst additional configurations are loaded subsequently.
    - `10-yes-antialias.conf`: Enables font antialiasing.
    - `30-metric-aliases.conf`: Defines fallback fonts that have similar metrics.
    - `49-sansserif.conf`: Maps sans-serif to specific fonts.
    - `60-latin.conf`: Latin script preferences (e.g., prioritize Noto Sans, then DejaVu).
    - `90-synthetic.conf`: Final synthetic font rules, fallback defaults.

## Font Types

Fonts are either represented as bitmap (a matrix of pixels) or a vector (bezier curves etc.)

Fonts are stored in different formats. `ttf` stands for True Type Font.

### Abstract Font Categories

The table shows the abstract font categories. They are not actual fonts, but _aliases_ to the actual font family under its umbrella.

| Generic Name | Meaning                             | Examples of Actual Fonts Mapped  |
| ------------ | ----------------------------------- | -------------------------------- |
| `monospace`  | Fixed-width (equal character width) | JetBrains Mono, DejaVu Sans Mono |
| `sans-serif` | Sans serif (no stroke endings)      | Noto Sans, Cantarell, Arial      |
| `serif`      | Serif fonts (with stroke endings)   | Times New Roman, Noto Serif      |
| `sans`       | Deprecated alias for `sans-serif`   | Same as above                    |
| `mono`       | Deprecated alias for `monospace`    | Same as `monospace`              |
| `system-ui`  | UI-designated default sans-serif    | Often maps to the OS’s default   |

Therefore, when a program wants to use a font, it can use these aliases to point to the actual font family you have installed. To see which what these aliases point to:

```bash
$ fc-match monospace
FreeMono.otf: "FreeMono" "Regular"
$ fc-match system-ui
FreeSans.otf: "FreeSans" "Regular"

$ fc-match -s monospace  # Display all matched fonts, starting from preferred to fallbacks
```

## Changing font preferences

A local font preference can be set by making and editing a file named `~/.config/fontconfig/fonts.conf` like:

```xml
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <match>
    <test name="family"><string>monospace</string></test>
    <edit name="family" mode="prepend">
      <string>JetBrains Mono</string>
    </edit>
  </match>
</fontconfig>
```

This essentially edits any reference to "monospace" to "JetBrains Mono".
