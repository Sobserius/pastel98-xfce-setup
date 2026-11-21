# Pastel98 XFCE Setup

A local snapshot of a Pastel98-themed XFCE desktop setup, including the theme, XFCE configuration, icon pack, cursor theme, wallpaper, and an easy installer.

## Contents

- `theme/Pastel98/` — XFCE/GTK/window-manager theme (for XFCE4)
- `icons/MoePinkIcons/` — icon pack used in this setup (MoePink/Moebuntu-style icons)
- `cursors/retrosmart-xcursor-white/` — cursor theme used (`retrosmart-xcursor-white`)
- `wallpapers/f231927664.png` — desktop wallpaper
- `config/xfce4/` — XFCE user config snapshot (xfconf channel XML files, panel launcher files, terminal/desktop helper files, keybinds)
- `local-share/xfce4/terminal/colorschemes/Pastel98.theme` — XFCE Terminal color scheme (Pastel98)
- `xfconf-dump/` — human-readable dumps of key xfconf channels from this setup
- `install.sh` — easy installer for applying the setup on another machine

## What gets configured

The included XFCE settings/config cover:
- **Theme/appearance**: GTK theme `Pastel98`, icon theme `MoePinkIcons`, cursor theme `retrosmart-xcursor-white`
- **Window manager (xfwm4)**: Pastel98 theme, compositing/shadow-related settings as in this snapshot
- **Panel (xfce4-panel)**: panel layout, plugins, clock/tasklist/menu settings, and launcher definitions in `config/xfce4/panel/`
- **Desktop**: wallpaper/background settings (installer rewrites the wallpaper path to the installed location)
- **Keyboard shortcuts**: XFCE keyboard shortcuts snapshot, including custom bindings:
  - **Super** (`Super_L`) → Applications Menu (`xfce4-popup-applicationsmenu`)
  - **Super + Space** → App Finder (`xfce4-appfinder`)
- **Terminal (xfce4-terminal)**: terminal preferences in `config/xfce4/terminal/terminalrc` and the Pastel98 terminal colorscheme in `local-share/xfce4/terminal/colorschemes/Pastel98.theme`
- **Other XFCE channels included**: `xsettings`, `xfce4-desktop`, `xfce4-panel`, `xfwm4`, `xfce4-session`, `xfce4-keyboard-shortcuts`, `xfce4-settings-manager`, `xfce4-terminal`, `thunar`, `displays`

> Note: applying `displays`, keyboard shortcuts, session, etc. will overwrite those user preferences. Backups are created by the installer for files it replaces.

## Requirements

- XFCE desktop environment (XFCE4)
- `bash`
- `xfconf-query` (usually provided by `xfconf`, part of XFCE) for live settings application
- Common XFCE components for full effect: `xfce4-panel`, `xfwm4`, `xfdesktop`, `xfce4-settings`, `xfce4-terminal`

## Easy install

```bash
git clone https://github.com/Sobserius/pastel98-xfce-setup.git
cd pastel98-xfce-setup
./install.sh
```

Or, if you already have the folder locally:

```bash
cd /path/to/Pastel98-xfce-setup
chmod +x install.sh
./install.sh
```

### What the installer does

- Installs theme to `~/.themes/Pastel98`
- Installs icons to `~/.icons/MoePinkIcons`
- Installs cursor theme to `~/.icons/retrosmart-xcursor-white`
- Installs wallpaper to `~/.local/share/backgrounds/Pastel98/f231927664.png`
- Copies/merges XFCE config files from `config/xfce4/` into `~/.config/xfce4/` (with timestamped backups of replaced files/dirs)
- Copies/merges XFCE local-share data from `local-share/xfce4/` into `~/.local/share/xfce4/` (e.g. terminal colorschemes)
- Rewrites wallpaper paths in copied `xfce4-desktop.xml` to the installed wallpaper path
- If running inside XFCE with `xfconf-query` available, applies key theme/icon/cursor/panel/wm/wallpaper settings live and reloads `xfdesktop`, `xfce4-panel`, and `xfwm4`

For best results, **log out and log back in** after installation so all XFCE components pick up the new settings.

## Manual install (optional)

1. Copy `theme/Pastel98` to `~/.themes/`
2. Copy `icons/MoePinkIcons` and `cursors/retrosmart-xcursor-white` to `~/.icons/`
3. Copy `wallpapers/f231927664.png` to a permanent location (e.g. `~/.local/share/backgrounds/Pastel98/`)
4. Copy desired files from `config/xfce4/` into `~/.config/xfce4/`
6. Copy `local-share/xfce4/terminal/colorschemes/Pastel98.theme` into `~/.local/share/xfce4/terminal/colorschemes/`
7. Set theme/icon/cursor/wallpaper in XFCE Appearance/Desktop Settings (or via `xfconf-query`)
8. Log out/in or restart XFCE components

## Notes & third-party assets

- This repository packages assets used by this local setup, including **MoePinkIcons** and **Retrosmart cursor** files as found on the source machine. Please check and comply with their respective upstream licenses/terms before redistribution or reuse beyond your own machine.
- Some panel launcher `.desktop` entries reference standard XFCE/system applications (terminal, file manager, web browser, app finder); availability depends on what is installed on the target system.
- The original setup was captured from a specific machine/user environment; monitor-specific desktop/wallpaper keys may need adjustment on different display layouts.


