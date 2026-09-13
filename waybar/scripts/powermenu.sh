#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  Rofi Power Menu
#  Provides a simple system power menu integrated with Waybar.
#  Example:
#      ./powermenu.sh
#      # Opens a Rofi menu with power options
# ─────────────────────────────────────────────────────────────────────────────

rofi_command="rofi -dmenu -p Power"

options="Shutdown\nReboot\nLogout\nSuspend"

chosen="$(echo -e "$options" | $rofi_command)"
case $chosen in
    Shutdown) systemctl poweroff ;;
    Reboot) systemctl reboot ;;
    Logout) hyprctl dispatch exit ;;
    Suspend) systemctl suspend ;;
esac
