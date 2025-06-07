#!/bin/bash

# Enhanced system stats script for hyprlock
# This script provides various system information

get_cpu_usage() {
    echo "CPU: $(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}' | cut -d. -f1)%"
}

get_memory_usage() {
    free | grep Mem | awk '{printf "RAM: %.0f%%", $3/$2 * 100.0}'
}

get_disk_usage() {
    df -h / | awk 'NR==2 {printf "💽 %s used", $5}'
}

get_temperature() {
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        temp=$(cat /sys/class/thermal/thermal_zone0/temp)
        temp_c=$((temp / 1000))
        if [ "$temp_c" -gt 70 ]; then
            icon="🔥"
        elif [ "$temp_c" -gt 50 ]; then
            icon="🌡️"
        else
            icon="❄️"
        fi
        echo "${icon} ${temp_c}°C"
    else
        echo "🌡️ --°C"
    fi
}

get_battery_status() {
    if [ -d /sys/class/power_supply/BAT* 2>/dev/null ]; then
        for bat in /sys/class/power_supply/BAT*; do
            if [ -f "$bat/capacity" ]; then
                cap=$(cat "$bat/capacity" 2>/dev/null || echo "0")
                status=$(cat "$bat/status" 2>/dev/null || echo "Unknown")
                
                case "$status" in
                    "Charging") icon="🔌" ;;
                    "Discharging") 
                        if [ "$cap" -le 20 ]; then
                            icon="🪫"
                        elif [ "$cap" -le 50 ]; then
                            icon="🔋"
                        else
                            icon="🔋"
                        fi
                        ;;
                    "Full") icon="🔋" ;;
                    *) icon="🔋" ;;
                esac
                
                echo "${icon} ${cap}%"
                break
            fi
        done
    fi
}

get_network_info() {
    # Get active network interface
    active_interface=$(ip route | grep default | awk '{print $5}' | head -1)
    
    if [ -n "$active_interface" ]; then
        # Check if it's wifi or ethernet
        if [[ "$active_interface" == wl* ]]; then
            # WiFi
            ssid=$(iwgetid -r 2>/dev/null || echo "Unknown")
            signal=$(cat /proc/net/wireless | grep "$active_interface" | awk '{print int($3 * 100 / 70)}' 2>/dev/null || echo "0")
            echo "📶 $ssid ($signal%)"
        else
            # Ethernet
            speed=$(ethtool "$active_interface" 2>/dev/null | grep "Speed:" | awk '{print $2}' || echo "Unknown")
            echo "🌐 Ethernet ($speed)"
        fi
    else
        echo "❌ No connection"
    fi
}

get_processes_count() {
    echo "🔢 $(ps aux | wc -l) processes"
}

get_load_average() {
    load=$(uptime | awk -F'load average:' '{print $2}' | awk -F',' '{print $1}' | xargs)
    echo "⚖️ Load: $load"
}

# Main execution based on argument
case "$1" in
    "cpu") get_cpu_usage ;;
    "memory") get_memory_usage ;;
    "disk") get_disk_usage ;;
    "temperature") get_temperature ;;
    "battery") get_battery_status ;;
    "network") get_network_info ;;
    "processes") get_processes_count ;;
    "load") get_load_average ;;
    *) 
        echo "Usage: $0 {cpu|memory|disk|temperature|battery|network|processes|load}"
        exit 1
        ;;
esac
