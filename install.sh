#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS="$(date +%Y%m%d-%H%M%S)"

THEME_NAME="Pastel98"
ICON_NAME="MoePinkIcons"
CURSOR_NAME="retrosmart-xcursor-white"
WALLPAPER_FILE="f231927664.png"

THEMES_DIR="$HOME/.themes"
ICONS_DIR="$HOME/.icons"
WALLPAPERS_DIR="$HOME/.local/share/backgrounds/$THEME_NAME"
XFCE_CONFIG_DIR="$HOME/.config/xfce4"
XFCE_LOCAL_SHARE_DIR="$HOME/.local/share/xfce4"
BACKUP_ROOT="$HOME/.config/pastel98-xfce-setup-backups/$TS"

info() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }

backup_path() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    local rel="${target#$HOME/}"
    local dest="$BACKUP_ROOT/$rel"
    mkdir -p "$(dirname "$dest")"
    cp -a "$target" "$dest"
    info "Backed up: $target -> $dest"
  fi
}

copy_replace_dir() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" || -L "$dst" ]]; then
    backup_path "$dst"
    rm -rf "$dst"
  fi
  cp -a "$src" "$dst"
  info "Installed: $dst"
}

copy_merge_tree() {
  local src="$1" dst="$2"
  mkdir -p "$dst"
  # Backup files that will be overwritten, then copy/merge
  while IFS= read -r -d '' f; do
    local rel="${f#$src/}"
    local target="$dst/$rel"
    mkdir -p "$(dirname "$target")"
    if [[ -e "$target" || -L "$target" ]]; then
      backup_path "$target"
    fi
    cp -a "$f" "$target"
  done < <(find "$src" -type f -print0)
  info "Merged config files into: $dst"
}

require_path() {
  [[ -e "$1" ]] || { echo "[ERROR] Missing required path: $1" >&2; exit 1; }
}

info "Pastel98 XFCE installer"
info "Source: $SCRIPT_DIR"

require_path "$SCRIPT_DIR/theme/$THEME_NAME"
require_path "$SCRIPT_DIR/icons/$ICON_NAME"
require_path "$SCRIPT_DIR/cursors/$CURSOR_NAME"
require_path "$SCRIPT_DIR/wallpapers/$WALLPAPER_FILE"
require_path "$SCRIPT_DIR/config/xfce4"
mkdir -p "$THEMES_DIR" "$ICONS_DIR" "$WALLPAPERS_DIR" "$XFCE_CONFIG_DIR" "$XFCE_LOCAL_SHARE_DIR" "$BACKUP_ROOT"

# Install theme, icons, cursor
copy_replace_dir "$SCRIPT_DIR/theme/$THEME_NAME" "$THEMES_DIR/$THEME_NAME"
copy_replace_dir "$SCRIPT_DIR/icons/$ICON_NAME" "$ICONS_DIR/$ICON_NAME"
copy_replace_dir "$SCRIPT_DIR/cursors/$CURSOR_NAME" "$ICONS_DIR/$CURSOR_NAME"

# Install wallpaper
if [[ -e "$WALLPAPERS_DIR/$WALLPAPER_FILE" || -L "$WALLPAPERS_DIR/$WALLPAPER_FILE" ]]; then
  backup_path "$WALLPAPERS_DIR/$WALLPAPER_FILE"
fi
cp -a "$SCRIPT_DIR/wallpapers/$WALLPAPER_FILE" "$WALLPAPERS_DIR/$WALLPAPER_FILE"
info "Installed wallpaper: $WALLPAPERS_DIR/$WALLPAPER_FILE"

# Install XFCE config snapshot
copy_merge_tree "$SCRIPT_DIR/config/xfce4" "$XFCE_CONFIG_DIR"

# Install XFCE local-share data (terminal colorschemes, etc.)
if [[ -d "$SCRIPT_DIR/local-share/xfce4" ]]; then
  copy_merge_tree "$SCRIPT_DIR/local-share/xfce4" "$XFCE_LOCAL_SHARE_DIR"
fi

# Rewrite hardcoded wallpaper paths in xfce4-desktop.xml (if present)
DESKTOP_XML="$XFCE_CONFIG_DIR/xfconf/xfce-perchannel-xml/xfce4-desktop.xml"
if [[ -f "$DESKTOP_XML" ]]; then
  # Replace known source path and any old absolute path variants pointing to the same filename in /home/sob
  sed -i \
    -e "s|/home/sob/Pictures/$WALLPAPER_FILE|$WALLPAPERS_DIR/$WALLPAPER_FILE|g" \
    -e "s|/home/[^\"<]*/$WALLPAPER_FILE|$WALLPAPERS_DIR/$WALLPAPER_FILE|g" \
    "$DESKTOP_XML"
  info "Updated wallpaper paths in: $DESKTOP_XML"
fi

apply_xfconf() {
  local channel="$1" prop="$2" type="$3" value="$4"
  if xfconf-query -c "$channel" -p "$prop" >/dev/null 2>&1; then
    xfconf-query -c "$channel" -p "$prop" -s "$value" >/dev/null 2>&1 || \
      xfconf-query -c "$channel" -p "$prop" -n -t "$type" -s "$value" >/dev/null 2>&1 || true
  else
    xfconf-query -c "$channel" -p "$prop" -n -t "$type" -s "$value" >/dev/null 2>&1 || true
  fi
}

if command -v xfconf-query >/dev/null 2>&1; then
  info "Applying key xfconf settings..."
  # Appearance/themes
  apply_xfconf xsettings /Net/ThemeName string "$THEME_NAME"
  apply_xfconf xsettings /Net/IconThemeName string "$ICON_NAME"
  apply_xfconf xsettings /Gtk/CursorThemeName string "$CURSOR_NAME"
  apply_xfconf xfwm4 /general/theme string "$THEME_NAME"
  apply_xfconf xfwm4 /general/show_frame_shadow bool false
  apply_xfconf xfwm4 /general/show_popup_shadow bool false
  apply_xfconf xfwm4 /general/show_dock_shadow bool false

  # Wallpaper (common keys + best-effort across detected monitors/workspaces)
  apply_xfconf xfce4-desktop /backdrop/screen0/monitor0/image-path string "$WALLPAPERS_DIR/$WALLPAPER_FILE"
  apply_xfconf xfce4-desktop /backdrop/screen0/monitor0/last-image string "$WALLPAPERS_DIR/$WALLPAPER_FILE"
  apply_xfconf xfce4-desktop /backdrop/screen0/monitor0/image-show bool true

  while IFS= read -r prop; do
    case "$prop" in
      */last-image|*/image-path)
        xfconf-query -c xfce4-desktop -p "$prop" -s "$WALLPAPERS_DIR/$WALLPAPER_FILE" >/dev/null 2>&1 || true
        ;;
      */image-show)
        xfconf-query -c xfce4-desktop -p "$prop" -s true >/dev/null 2>&1 || true
        ;;
    esac
  done < <(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep -E '/(last-image|image-path|image-show)$' || true)

  info "xfconf settings applied (best effort)."
else
  warn "xfconf-query not found; copied config files but could not apply live xfconf settings."
fi

# Reload components if available (best effort, useful inside a running XFCE session)
if pgrep -x xfdesktop >/dev/null 2>&1 && command -v xfdesktop >/dev/null 2>&1; then
  xfdesktop --reload >/dev/null 2>&1 || true
  info "Reloaded xfdesktop."
fi
if pgrep -x xfce4-panel >/dev/null 2>&1 && command -v xfce4-panel >/dev/null 2>&1; then
  xfce4-panel -r >/dev/null 2>&1 || true
  info "Restarted xfce4-panel."
fi
if pgrep -x xfwm4 >/dev/null 2>&1 && command -v xfwm4 >/dev/null 2>&1; then
  xfwm4 --replace >/dev/null 2>&1 &
  disown || true
  info "Requested xfwm4 replace."
fi

printf '\n'
info "Installation complete."
info "Theme:   $THEMES_DIR/$THEME_NAME"
info "Icons:   $ICONS_DIR/$ICON_NAME"
info "Cursor:  $ICONS_DIR/$CURSOR_NAME"
info "Wallpaper: $WALLPAPERS_DIR/$WALLPAPER_FILE"
if [[ -d "$SCRIPT_DIR/local-share/xfce4" ]]; then
  info "XFCE local data: $XFCE_LOCAL_SHARE_DIR (merged)"
fi
info "Backups: $BACKUP_ROOT"
info "Log out and log back in for all XFCE settings to take full effect."
