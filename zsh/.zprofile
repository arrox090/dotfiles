# ==========================================
# UNIVERSAL ENVIRONMENT VARIABLES (Mac & Arch)
# ==========================================
export EDITOR="nvim"
export SUDO_EDITOR="$EDITOR"
export BAT_THEME="Catppuccin Mocha"
export ZVM_VI_EDITOR="$EDITOR"
# export ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
# export ZVM_SYSTEM_CLIPBOARD_ENABLED=true
export PAGER="nvimpager"
export MANPAGER="$PAGER"

# For manual builds / custom scripts mostly
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/go/bin:$HOME/.tmuxifier/bin:$PATH"

# ==========================================
# macOS SPECIFIC (Darwin)
# ==========================================
if [[ "$(uname -s)" == "Darwin" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  export DOTNET_ROOT="$(brew --prefix dotnet)/libexec"
  export PATH="/Library/Frameworks/Python.framework/Versions/3.13/bin:$PATH"

  # Autostart LocalSend inside isolated tmux socket
  tmux -L services has-session -t localsend 2>/dev/null || \
    tmux -L services new-session -d -s localsend "localsend-cli --port 53318"

# ==========================================
# ARCH LINUX SPECIFIC
# ==========================================
elif [[ -f /etc/arch-release ]]; then
  # Autostart Hyprland via UWSM on TTY1 login
  if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
    exec uwsm start hyprland.desktop
  fi

  # so himalaya does not show those warnings that do nothing
  export RUST_LOG=himalaya=off
fi
