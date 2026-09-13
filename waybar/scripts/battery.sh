#!/bin/bash

battery=$(find /sys/class/power_supply -maxdepth 1 -type l \
    -exec basename {} \; | grep '^BAT' | head -n1)

if [[ -z "$battery" ]]; then
    echo '{"text":"󰂑","tooltip":"No battery detected"}'
    exit 0
fi

capacity=$(cat "/sys/class/power_supply/$battery/capacity")
status=$(cat "/sys/class/power_supply/$battery/status")

battery_device="battery_$battery"

time_to_empty=$(upower -i "/org/freedesktop/UPower/devices/$battery_device" 2>/dev/null |
    awk -F: '/time to empty/ {print $2}' | xargs)

time_to_full=$(upower -i "/org/freedesktop/UPower/devices/$battery_device" 2>/dev/null |
    awk -F: '/time to full/ {print $2}' | xargs)

charging_icons=(󰢜 󰂆 󰂇 󰂈 󰢝 󰂉 󰢞 󰂊 󰂋 󰂅)
default_icons=(󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹)

index=$((capacity / 10))
[ "$index" -ge 10 ] && index=9

if [[ "$status" == "Charging" ]]; then
    icon=${charging_icons[$index]}
elif [[ "$status" == "Full" ]]; then
    icon="󰂅"
else
    icon=${default_icons[$index]}
fi

if [ "$capacity" -lt 20 ]; then
    fg="#bf616a"
elif [ "$capacity" -lt 55 ]; then
    fg="#fab387"
else
    fg="#56b6c2"
fi

profile=$(powerprofilesctl get 2>/dev/null)

case "$profile" in
    performance)
        profile_name="⚡ Performance"
        ;;
    balanced)
        profile_name="⚖ Balanced"
        ;;
    power-saver)
        profile_name="🔋 Power Saver"
        ;;
    *)
        profile_name="Unknown"
        ;;
esac

if [[ "$status" == "Charging" ]]; then
    tooltip="Batería: $capacity%\\nPower mode: $profile_name\\nCharging: ${time_to_full:-Unknown}"
elif [[ "$status" == "Full" ]]; then
    tooltip="Batería: $capacity%\\nPower mode: $profile_name\\nFully charged"
else
    tooltip="Batería: $capacity%\\nPower mode: $profile_name\\nTime remaining: ${time_to_empty:-Unknown}"
fi

echo "{\"text\":\"<span foreground='$fg'>$icon</span>\",\"tooltip\":\"$tooltip\"}"
