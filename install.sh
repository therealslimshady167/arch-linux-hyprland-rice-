#!/bin/bash

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
LOCAL_BIN="$HOME/.local/bin"
BACKUP_DIR="$HOME/.config/arch-rice-backup-$(date +%Y%m%d-%H%M%S)"

echo "==> Arch Rice Installer"
echo "Repository: $REPO_DIR"
echo

echo "==> Installing packages..."
sudo pacman -S --needed - < "$REPO_DIR/packages.txt"

echo
echo "==> Creating directories..."
mkdir -p "$CONFIG_DIR"
mkdir -p "$LOCAL_BIN"

echo
echo "==> Backing up existing configs..."
mkdir -p "$BACKUP_DIR"

for dir in hypr waybar kitty rofi wofi cava; do
    if [[ -d "$CONFIG_DIR/$dir" ]]; then
        echo "Backing up ~/.config/$dir"
        cp -a "$CONFIG_DIR/$dir" "$BACKUP_DIR/"
    fi
done

echo "Backup stored at:"
echo "$BACKUP_DIR"

echo
echo "==> Installing configs..."

rm -rf "$CONFIG_DIR/hypr"
cp -a "$REPO_DIR/hypr" "$CONFIG_DIR/"
mkdir -p "$CONFIG_DIR/hypr/wallpapers"
cp -a "$REPO_DIR/wallpapers/." "$CONFIG_DIR/hypr/wallpapers/"
rm -rf "$CONFIG_DIR/waybar"
cp -a "$REPO_DIR/waybar" "$CONFIG_DIR/"

rm -rf "$CONFIG_DIR/kitty"
cp -a "$REPO_DIR/kitty" "$CONFIG_DIR/"

rm -rf "$CONFIG_DIR/rofi"
cp -a "$REPO_DIR/rofi" "$CONFIG_DIR/"

rm -rf "$CONFIG_DIR/wofi"
cp -a "$REPO_DIR/wofi" "$CONFIG_DIR/"

rm -rf "$CONFIG_DIR/cava"
cp -a "$REPO_DIR/cava" "$CONFIG_DIR/"

echo
echo "==> Installing CAVA wrappers..."

install -Dm755 "$REPO_DIR/cava/cava" "$LOCAL_BIN/cava"
install -Dm755 "$REPO_DIR/cava/cava-braille" "$LOCAL_BIN/cava-braille"

echo
echo "==> Fixing script permissions..."

find "$CONFIG_DIR/hypr" "$CONFIG_DIR/waybar" \
    -type f \( -name '*.sh' -o -name '*.py' \) \
    -exec chmod +x {} +

echo
echo "==> Installation complete."
echo
echo "Backups:"
echo "$BACKUP_DIR"
echo
echo "Restart Waybar/Hyprland or log out and back in for everything to load."
