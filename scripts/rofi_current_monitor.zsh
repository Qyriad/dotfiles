#!/bin/zsh

# I hate this

OUTPUT_POS=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused).rect | "\(.width)x\(.height)\\+\(.x)\\+\(.y)"')
XWAYLAND_OUTPUT=$(xrandr | rg -oP "XWAYLAND[0-9](?= connected $OUTPUT_POS)")
ROFI_ID=$(rofi --help | rg "$XWAYLAND_OUTPUT" -B 1 | head -1 | rg -o '\d+')
print -n $ROFI_ID
