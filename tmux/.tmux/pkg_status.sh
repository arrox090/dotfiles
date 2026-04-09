#!/bin/sh

CACHE_FILE="/tmp/tmux_package_update_count"
CACHE_TIME=3600 # update every hour

if [ -f "$CACHE_FILE"] && [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -lt $CACHE_TIME ]; then
  UPDATES=$(cat "$CACHE_FILE")
else
  if uname | grep -q Darwin; then
    # macOS → brew
    UPDATES=$(brew outdated --quiet | wc -l | tr -d ' \n')
  else
    # Arch Linux → yay
    UPDATES=$(yay -Qu 2>/dev/null | wc -l | tr -d ' \n')
  fi

  echo "$UPDATES" >"$CACHE_FILE"
fi

if uname | grep -q Darwin; then
  echo "#[bg=#{@thm_bg},fg=#{@thm_mauve}] ⚡ ${UPDATES} brew "
else
  echo "#[bg=#{@thm_bg},fg=#{@thm_blue}]  ${UPDATES} yay "
fi
