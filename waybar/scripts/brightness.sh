#!/bin/bash

# Get brightness percentage
brightness=$(brightnessctl get)
max_brightness=$(brightnessctl max)
percent=$((brightness * 100 / max_brightness))

# Icon
icon="󰛨"

# Color thresholds
if [ "$percent" -lt 20 ]; then
    fg="#bf616a"
elif [ "$percent" -lt 55 ]; then
    fg="#fab387"
else
    fg="#56b6c2"
fi


# Tooltip
tooltip="La Luminosità: $percent%"

# Icon only
echo "{\"text\":\"<span foreground='$fg'>$icon</span>\",\"tooltip\":\"$tooltip\"}"
