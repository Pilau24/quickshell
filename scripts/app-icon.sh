#!/usr/bin/env bash
# Usage: app-icon.sh <app-name>
# Prints the icon file path from the app's .desktop Icon= key, or prints nothing.

name="${1:-}"
[ -n "$name" ] || exit 0

app_dirs=(
  "$HOME/.local/share/applications"
  "/usr/share/applications"
  "/usr/local/share/applications"
  "/var/lib/flatpak/exports/share/applications"
  "$HOME/.local/share/flatpak/exports/share/applications"
)

desktop=""
for d in "${app_dirs[@]}"; do
  if [ -f "$d/$name.desktop" ]; then
    desktop="$d/$name.desktop"
    break
  fi
done

# Fall back to a case-insensitive filename match.
if [ -z "$desktop" ]; then
  for d in "${app_dirs[@]}"; do
    [ -d "$d" ] || continue
    found=$(find "$d" -maxdepth 1 -iname "$name.desktop" 2>/dev/null | head -n 1)
    if [ -n "$found" ]; then
      desktop="$found"
      break
    fi
  done
fi
[ -n "$desktop" ] || exit 0

icon=$(sed -n 's/^Icon=//p' "$desktop" | head -n 1)
[ -n "$icon" ] || exit 0

# Absolute icon paths are used as-is.
if [ "${icon#/}" != "$icon" ]; then
  [ -f "$icon" ] && printf '%s\n' "$icon"
  exit 0
fi

icon_dirs=(
  "$HOME/.local/share/icons"
  "/usr/share/icons"
  "/usr/share/pixmaps"
)

for ext in png svg xpm; do
  for base in "${icon_dirs[@]}"; do
    [ -d "$base" ] || continue
    found=$(find "$base" -name "$icon.$ext" 2>/dev/null | grep -m 1 -E '/apps/|/pixmaps/')
    if [ -n "$found" ]; then
      printf '%s\n' "$found"
      exit 0
    fi
  done
done
