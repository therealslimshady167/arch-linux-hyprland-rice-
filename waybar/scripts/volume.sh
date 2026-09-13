#!/bin/bash

volume_info=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)

vol_raw=$(echo "$volume_info" | awk '{print $2}')
vol_int=$(awk "BEGIN {printf \"%d\", $vol_raw * 100}")

if echo "$volume_info" | grep -q "MUTED"; then
    icon=""
    tooltip="Resonance: Muted"
else
    if [ "$vol_int" -lt 50 ]; then
        icon=""
    else
        icon=""
    fi

    tooltip="Resonance: $vol_int%"
fi

printf '{"text":"%s","tooltip":"%s"}\n' "$icon" "$tooltip"
