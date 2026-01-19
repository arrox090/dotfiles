#!/bin/sh

if uname | grep -q Darwin; then
  # macOS → brew
  echo "#[bg=#{@thm_bg},fg=#{@thm_mauve}] ⚡ $(brew outdated --quiet | wc -l | tr -d ' \n') brew "
else
  # Arch Linux → yay
  echo "#[bg=#{@thm_bg},fg=#{@thm_blue}]  $(yay -Qu 2>/dev/null | wc -l | tr -d ' \n') yay "
fi
