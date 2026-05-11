#!/bin/bash

case $1 in
google-chrome | google-chrome-stable)
  config_folder="google-chrome"
  ;;
brave)
  config_folder="BraveSoftware/Brave-Browser"
  ;;
*)
  # strip "-browser" from the end of the string
  config_folder="${browser_bin%-browser}"
  ;;
esac

preferences_file="$HOME/.config/$config_folder/Default/Preferences"

if [ -f "$preferences_file" ]; then
  # Clear the crash flags
  sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' "$preferences_file"
  sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' "$preferences_file"
fi

# Launch the browser
exec "$@"
