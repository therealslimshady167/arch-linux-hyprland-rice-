#!/bin/bash

usage=$(top -bn1 | awk '/Cpu\(s\)/ {print 100 - $8}' | awk '{printf "%d", $1}')

echo "{\"text\":\"󰻠\",\"tooltip\":\"CPU: $usage%\"}"
