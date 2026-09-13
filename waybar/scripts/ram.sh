#!/bin/bash

read -r total used <<< "$(free -h | awk '/Mem:/ {print $2, $3}')"

echo "{\"text\":\"󰍛\",\"tooltip\":\"RAM: $used / $total\"}"
