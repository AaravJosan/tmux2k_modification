#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

weather_scale=$(get_tmux_option "@tmux2k-weather-scale" "c")
display_condition=$(get_tmux_option "@tmux2k-weather-display-condition" true)
display_location=$(get_tmux_option "@tmux2k-weather-display-location" false)
fixed_location=$(get_tmux_option "@tmux2k-weather-location" "")

declare -A weather_icons=(
  ["Clear"]=""
  ["Cloud"]=""
  ["Drizzle"]="󰖗"
  ["Fog"]=""
  ["Haze"]="󰼰"
  ["Mist"]=""
  ["Overcast"]=""
  ["Rain"]=""
  ["Sand"]=""
  ["Shower"]=""
  ["Smoke"]=""
  ["Snow"]=""
  ["Sunny"]=""
  ["Thunderstorm"]=""
  ["Tornado"]="󰼸"
  ["Windy"]="󰖝"
)

fetch_weather_location() {
  if [[ -n "$fixed_location" ]]; then
    echo "$fixed_location"
  else
    city=$(curl -s https://ipinfo.io/city?token= 2>/dev/null) # alternative: ifconfig.co
    echo "$city"
  fi
}

fetch_weather_information() {

  case $weather_scale in

  f) scale='u' ;;

  k) scale='M' ;;

  *) scale='m' ;;

  esac

  encoded_location="${1// /+}"

  curl -sL "https://wttr.in/${encoded_location}?format=%C:%t&${scale}"

}

# fetch_weather_information() {
#   case $weather_scale in
#   f) scale='&u' ;;
#   k) scale='&M' ;;
#   *) scale='&m' ;;
#   esac
#   curl -sL "wttr.in/$1?format=%C+%t$scale"
# }

forecast_unicode() {
  local condition="$1"

  # handle empty or weird values safely
  if [[ -z "$condition" ]]; then
    echo ' '
    return
  fi

  # normalize condition (strip spaces / only take first word)
  condition="${condition%% *}"

  weather_icon="${weather_icons[$condition]}"

  if [[ -n "$weather_icon" ]]; then
    echo "$weather_icon "
  else
    echo ' '
  fi
}

# forecast_unicode() {
#   local condition=$1
#   weather_icon="${weather_icons[$condition]}"
#   if [[ -n $weather_icon ]]; then
#     echo "$weather_icon "
#   else
#     echo ' '
#   fi
# }

main() {
  location=$(fetch_weather_location)
  weather_information=$(fetch_weather_information "$location")

  condition="${weather_information%%:*}"
  temperature="${weather_information##*:}"
  temperature="${temperature/+/}"

  # condition=$(echo "$weather_information" | rev | cut -d ' ' -f2- | tr -d '[:space:]' | rev)
  # temperature=$(echo "$weather_information" | rev | cut -d ' ' -f 1 | rev)
  unicode=$(forecast_unicode "$condition")

  if [[ $display_condition == "true" ]]; then
    condition=" $condition"
  else
    condition=""
  fi
  if [[ $display_location == "true" ]]; then
    location=" $location"
  else
    location=""
  fi
  echo "$unicode${temperature/+/}$condition$location"
}

main
