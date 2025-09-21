#!/bin/bash

# Set your city here
CITY="###"

# User agent to avoid Nominatim ban
UA="Mozilla/5.0"

# Cache location
CACHE_FILE="$HOME/.cache/weather.txt"

# Get coordinates
coords=$(curl -s -A "$UA" "https://nominatim.openstreetmap.org/search?format=json&q=${CITY// /+}" | jq -r ".[0] | .lat + \",\" + .lon")
lat=${coords%%,*}
lon=${coords##*,}

# Get weather
weather_data=$(curl -s --max-time 5 "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&hourly=temperature_2m,relative_humidity_2m,apparent_temperature,wind_speed_10m,wind_direction_10m&temperature_unit=celsius&wind_speed_unit=kmh&timezone=America%2FToronto&forecast_days=1")

# Extract data
temp=$(echo "$weather_data" | jq -r ".current_weather.temperature // empty" | cut -d. -f1)
code=$(echo "$weather_data" | jq -r ".current_weather.weathercode // empty")
wind_speed=$(echo "$weather_data" | jq -r ".current_weather.windspeed // empty" | cut -d. -f1)
wind_dir=$(echo "$weather_data" | jq -r ".current_weather.winddirection // empty")
hour=$(date +%H)
humidity=$(echo "$weather_data" | jq -r ".hourly.relative_humidity_2m[$hour] // empty")
feels_like=$(echo "$weather_data" | jq -r ".hourly.apparent_temperature[$hour] // empty" | cut -d. -f1)

# Choose icon
case "$code" in
0) icon="☀️" ;;
1 | 2 | 3) icon="🌤️" ;;
45 | 48) icon="🌫️" ;;
51 | 53 | 55 | 56 | 57) icon="🌦️" ;;
61 | 63 | 65 | 66 | 67 | 80 | 81 | 82) icon="🌧️" ;;
71 | 73 | 75 | 77 | 85 | 86) icon="❄️" ;;
95 | 96 | 99) icon="⛈️" ;;
*) icon="🌤️" ;;
esac

# Wind direction arrow
arrow=""
if [ -n "$wind_dir" ]; then
  if [ "$wind_dir" -ge 338 ] || [ "$wind_dir" -lt 23 ]; then
    arrow="↓"
  elif [ "$wind_dir" -ge 23 ] && [ "$wind_dir" -lt 68 ]; then
    arrow="↙"
  elif [ "$wind_dir" -ge 68 ] && [ "$wind_dir" -lt 113 ]; then
    arrow="←"
  elif [ "$wind_dir" -ge 113 ] && [ "$wind_dir" -lt 158 ]; then
    arrow="↖"
  elif [ "$wind_dir" -ge 158 ] && [ "$wind_dir" -lt 203 ]; then
    arrow="↑"
  elif [ "$wind_dir" -ge 203 ] && [ "$wind_dir" -lt 248 ]; then
    arrow="↗"
  elif [ "$wind_dir" -ge 248 ] && [ "$wind_dir" -lt 293 ]; then
    arrow="→"
  elif [ "$wind_dir" -ge 293 ] && [ "$wind_dir" -lt 338 ]; then
    arrow="↘"
  fi
fi

# Build output lines
line1="${icon:-🌤️} ${temp:---}°C"
[ -n "$feels_like" ] && [ "$feels_like" != "$temp" ] && line1+=" (Feels ${feels_like}°C)"

line2=""
[ -n "$wind_speed" ] && line2+="💨 ${wind_speed}km/h ${arrow}"

line3=""
[ -n "$humidity" ] && line3+="💧 ${humidity}%"

# Save to cache with each info on its own line
{
  echo "$line1"
  [ -n "$line2" ] && echo "$line2"
  [ -n "$line3" ] && echo "$line3"
} >"$CACHE_FILE"
