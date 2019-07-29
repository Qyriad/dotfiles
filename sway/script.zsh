#!/bin/zsh
swaymsg -t get_workspaces -r | jq '.[] | if .focused == true then . else null end | values | {num, name, focused, output}'
