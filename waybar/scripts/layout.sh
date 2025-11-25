#!/bin/bash

layout=$(hyprctl devices -j | jq -r '.keyboards[0].active_keymap')

case "$layout" in
    "English (US)")
        echo "EN"
        ;;
    "Russian")
        echo "RU"
        ;;
    *)
        echo "??"
        ;;
esac
