#!/usr/bin/sh

# Set wallpaper
nitrogen --restore &

# Enable touchpad clicks
xinput set-prop "$(xinput list --name-only | grep -i touch)" "libinput Tapping Enabled" 1
