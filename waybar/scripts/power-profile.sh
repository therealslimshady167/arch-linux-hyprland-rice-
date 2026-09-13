#!/bin/bash

choice=$(printf '%s\n' \
    "⚡ Performance" \
    "⚖ Balanced" \
    "🔋 Power Saver" | rofi -dmenu -p "Power Mode")

case "$choice" in
    "⚡ Performance")
        powerprofilesctl set performance
        ;;
    "⚖ Balanced")
        powerprofilesctl set balanced
        ;;
    "🔋 Power Saver")
        powerprofilesctl set power-saver
        ;;
esac
