if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
  exec uwsm start hyprland.desktop
fi

