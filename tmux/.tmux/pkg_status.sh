#!/bin/sh

if uname | grep -q Darwin; then
  # macOS → just brew outdated
  echo "#[bg=#{@thm_bg},fg=#{@thm_mauve}] ⚡ $(brew outdated --quiet | wc -l | tr -d ' \n') brew "
else
  # Arch Linux → pacman + separator + yay
  pacman_updates=$(checkupdates 2>/dev/null | wc -l | tr -d ' \n')
  aur_updates=$(yay -Qu 2>/dev/null | wc -l | tr -d ' \n')

  echo "#[bg=#{@thm_bg},fg=#{@thm_mauve}]  ${pacman_updates} pacman " \
       "#[bg=#{@thm_bg},fg=#{@thm_overlay_0},none]│" \
       "#[bg=#{@thm_bg},fg=#{@thm_blue}] ⚡${aur_updates} AUR "
fi
