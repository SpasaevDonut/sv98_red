#!/bin/bash

# Иконки (Nerd Fonts)
ICON_CONNECTED=""
ICON_DISCONNECTED="睊"
ICON_WIFI_OFF="直"

# Получаем текущее состояние Wi-Fi
get_wifi_status() {
    if nmcli radio wifi | grep -q "enabled"; then
        if nmcli -t -f active,ssid dev wifi | grep -q '^yes'; then
            echo "$ICON_CONNECTED"
        else
            echo "$ICON_DISCONNECTED"
        fi
    else
        echo "$ICON_WIFI_OFF"
    fi
}

# Получаем текущую сеть
get_current_network() {
    nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2
}

# Показать меню с сетями (через zenity)
show_wifi_menu() {
    # Получаем список сетей с уровнем сигнала и защитой
    networks=$(nmcli -t -f ssid,security,signal dev wifi | awk -F': ' '{
        split($2, sec, " ");
        icon = (sec[1] == "--" ? "" : "🔒 ");
        printf "%s %s (%s%%)\n" "'"$icon"'", $1, $3
    }' | sort -k3 -nr)

    # Показываем меню через zenity
    selected=$(echo -e "Wi-Fi Off\n$networks" | zenity --list --title="Wi-Fi Networks" --column="Network" --width=400 --height=300)

    if [ "$selected" = "Wi-Fi Off" ]; then
        nmcli radio wifi off
        notify-send "Wi-Fi" "Turned off"
    elif [ -n "$selected" ]; then
        ssid=$(echo "$selected" | awk '{print $1}')
        nmcli dev wifi connect "$ssid" >/dev/null 2>&1
        notify-send "Wi-Fi" "Connecting to $ssid..."
    fi
}

# Переключить Wi-Fi
toggle_wifi() {
    if nmcli radio wifi | grep -q "enabled"; then
        nmcli radio wifi off
        notify-send "Wi-Fi" "Turned off"
    else
        nmcli radio wifi on
        notify-send "Wi-Fi" "Turned on"
    fi
}

# Основная логика
if [ "$1" = "--status" ]; then
    status=$(get_wifi_status)
    network=$(get_current_network)
    if [ -n "$network" ]; then
        echo "{\"text\": \"$status\", \"tooltip\": \"Connected: $network\"}"
    else
        echo "{\"text\": \"$status\", \"tooltip\": \"Wi-Fi: Disconnected\"}"
    fi
elif [ "$1" = "--toggle" ]; then
    toggle_wifi
elif [ "$1" = "--menu" ]; then
    show_wifi_menu
fi
