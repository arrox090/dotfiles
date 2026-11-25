###################################
# OS DETECTION
###################################
os="$(uname -s)"

###################################
# Added by Zinit's installer
###################################
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
  print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
  command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
  command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" &&
    print -P "%F{33} %F{34}Installation successful.%f%b" ||
    print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
((${+_comps})) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust

###################################
# LOAD TOOLS
###################################
autoload -Uz compinit && compinit

###################################
# PLUGINS
###################################
zinit light zdharma-continuum/fast-syntax-highlighting
# zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit light jeffreytse/zsh-vi-mode

###################################
# EVAL
###################################
eval "$(tmuxifier init -)"
eval "$(zoxide init zsh)"

# Prevent recursive wrapping of zle-keymap-select when re-sourcing ~/.zshrc:
zle -D zle-keymap-select 2>/dev/null
eval "$(starship init zsh)"

# eval "$(uv generate-shell-completion zsh)"

###################################
# MAKE fzf tab work for tmuxifier completions
###################################
_tmuxifier_compat() {
  compadd -- $(tmuxifier commands)
}
compdef _tmuxifier_compat tmuxifier

###################################
# ALIASES
###################################
alias vz='nvim ~/.zshrc'
alias sz='source ~/.zshrc && echo ~/.zshrc sourced'

alias svim='sudo -E nvim'

if [[ "$os" == "Darwin" ]]; then
  alias wattage="ioreg -r -n AppleSmartBattery | awk '/\"Amperage\" =/{a=\$3} /\"Voltage\" =/{v=\$3} END {print (a*v)/1000000 \" W\"}'"
  alias lsend="localsend-cli send"
  alias lsa="tmux -L services attach -t localsend"
  alias lsk="tmux -L services kill-session -t localsend"
  alias lsr="tmux -L services kill-session -t localsend 2>/dev/null; tmux -L services new-session -d -s localsend 'localsend-cli --port 53318'"

  jhome() {
    export JAVA_HOME=$(/usr/libexec/java_home -v "$1")
    echo $(/usr/libexec/java_home -v "$1")
  }

  shareurl() {
    if [[ -z "$1" ]]; then
      echo "Usage: shareurl <URL> [filename]"
      return 1
    fi

    local url="$1"
    local name="${2:-Open Link}"
    local file="${name}.webloc"

    cat >"/tmp/$file" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>URL</key>
  <string>${url}</string>
</dict>
</plist>
EOF

    echo "Created: /tmp/$file"
  }

fi

alias runc='function _runc(){ gcc "$1" -o main && ./main; }; _runc'
alias runcpp='function _runcpp(){ g++ "$1" -o main && ./main; }; _runcpp'
alias runjava='function _runjava(){ javac "$1" && java "${1%.*}"; }; _runjava'

alias c='clear'
alias nv='nvim'
alias ls='eza -l --icons=always'

alias cd="zd"
zd() {
  if [ $# -eq 0 ]; then
    builtin cd ~ && return
  elif [ -d "$1" ]; then
    builtin cd "$1"
  else
    z "$@" && printf "\U000F17A9 " && pwd || echo "Error: Directory not found"
  fi
}

alias ..='cd ..'

###################################
# KEYBINDS
###################################
fzf-history-widget() {
  local orig_buffer=$BUFFER # save what was typed
  local orig_cursor=$CURSOR

  # run fzf on history
  local selected
  selected=$(fc -rl 1 | awk '{$1=""; print substr($0,2)}' | awk '!seen[$0]++' | fzf --tac --query "$LBUFFER")

  if [[ -n $selected ]]; then
    BUFFER=$selected
    CURSOR=${#BUFFER}
  else
    # restore original if nothing selected
    BUFFER=$orig_buffer
    CURSOR=$orig_cursor
  fi

  zle reset-prompt
}
zle -N fzf-history-widget

# Paste contents in the same line not the next one
_zvm_put_inline() {
  CUTBUFFER="${CUTBUFFER#$'\n'}"
  CUTBUFFER="${CUTBUFFER%$'\n'}"
  zle vi-put-before
}
zle -N _zvm_put_inline

function zvm_after_init() {
  # Remove not needed, conflicting keybinds
  bindkey -r '^L'
  bindkey -r '^K'
  bindkey -r '^J'
  bindkey -r '^H'
  bindkey -r '^R'

  bindkey '^R' fzf-history-widget

  # Handle Option+Backspace (delete word backwards) across both DEL (^?) and BS (^H) terminals
  bindkey '^[^?' backward-kill-word
  bindkey '^[^H' backward-kill-word
}

# For vicmd keybinds here so they are not overwritten
function zvm_after_lazy_keybindings() {
  zvm_bindkey vicmd 'p' _zvm_put_inline
}

###################################
# OPTIONS
###################################
setopt CORRECT

# Make auto complete case insensitive
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Remove highlight of pasted text
zle_highlight+=(paste:none)

###################################
# COPY TOOL FOR COPYING WHEN IN SSH (osc52)
###################################
if [[ "$os" == "Linux" ]]; then
  rclip() {
    local text
    text=$(cat)
    local b64
    b64=$(printf '%s' "$text" | base64 | tr -d '\n')
    printf '\033]52;c;%s\a' "$b64"
  }
fi

###################################
# COMMAND HISTORY SETTINGS
###################################
HISTSIZE=5000
SAVEHIST=5000
HISTFILE=~/.zsh_history

# Append to history file instead of overwriting
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY # save after each command
setopt SHARE_HISTORY      # share history across terminals
setopt HIST_IGNORE_DUPS   # ignore consecutive duplicates
setopt HIST_REDUCE_BLANKS # strip the command string

alias nvim-lazy='NVIM_APPNAME="nvim-lazyvim" nvim'
# rm -rf ~/.config/nvim-lazyvim ~/.local/share/nvim-lazyvim ~/.cache/nvim-lazyvim ~/.local/state/nvim-lazyvim

alias nvim-nvchad='NVIM_APPNAME="nvim-nvchad" nvim'
# rm -rf ~/.config/nvim-nvchad ~/.local/share/nvim-nvchad ~/.cache/nvim-nvchad ~/.local/state/nvim-nvchad

alias nvim-astro='NVIM_APPNAME="nvim-astronvim" nvim'
# rm -rf ~/.config/nvim-astronvim ~/.local/share/nvim-astronvim ~/.cache/nvim-astronvim ~/.local/state/nvim-astronvim

###################################################################
# EXPORT SETTINGS FOR ZLE
###################################################################

# Remove '/' from WORDCHARS so Option+Backspace / Ctrl+W deletes paths segment by segment:
export WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

###################################################################
# DOTFILES UPDATE CHECK (Debounced 6h, Fully Async & Signal-Driven)
###################################################################

# Signal handler: asynchronously draws notification above the active prompt
TRAPUSR1() {
  local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}"
  local status_file="$cache_dir/dotfiles_status"
  local notify_file="$cache_dir/dotfiles_notify"

  if [[ -f "$notify_file" && -f "$status_file" ]]; then
    rm -f "$notify_file"
    local target_sha msg
    {
      read -r target_sha
      read -r msg
    } <"$status_file"

    if [[ -n "$msg" && -z "$_DOTFILES_NOTIFIED" ]]; then
      typeset -g _DOTFILES_NOTIFIED=1
      zle -I 2>/dev/null
      print -P "$msg"
      zle -R 2>/dev/null
    fi
  fi
  return 0
}

_check_dotfiles_update() {
  local dotfiles_dir
  if [[ "$os" == "Darwin" ]]; then
    dotfiles_dir="$HOME/dotfiles"
  else
    dotfiles_dir="$HOME/projects/dotfiles"
  fi

  [[ -d "$dotfiles_dir/.git" ]] || return

  local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}"
  local status_file="$cache_dir/dotfiles_status"
  local stamp_file="$cache_dir/dotfiles_last_check"
  local notify_file="$cache_dir/dotfiles_notify"

  zmodload zsh/datetime 2>/dev/null
  local now=$EPOCHSECONDS
  local last_check=0
  [[ -f "$stamp_file" ]] && read -r last_check <"$stamp_file"

  # Only show cache if within 6h of last check
  if ((now - last_check <= 21600)) && [[ -f "$status_file" ]]; then
    local target_sha msg
    {
      read -r target_sha
      read -r msg
    } <"$status_file"
    local current_sha
    current_sha=$(git -C "$dotfiles_dir" rev-parse HEAD 2>/dev/null)

    # Auto-cleanup cache if local repository is already up to date with remote
    if [[ -n "$target_sha" && "$current_sha" == "$target_sha" ]]; then
      rm -f "$status_file" "$notify_file"
      unset _DOTFILES_NOTIFIED
    elif [[ -n "$msg" ]]; then
      print -P "$msg"
      typeset -g _DOTFILES_NOTIFIED=1
    fi
  fi

  # If over 6h then fetch asynchronously new state and send USR1 signal
  if ((now - last_check > 21600)); then
    print -r -- "$now" >"$stamp_file"
    local parent_pid=$$

    # Background fetch fully detached to prevent any SSH/TTY delay
    (
      git -C "$dotfiles_dir" fetch --quiet origin main 2>/dev/null || exit 0

      local counts
      counts=$(git -C "$dotfiles_dir" rev-list --left-right --count HEAD...origin/main 2>/dev/null)
      [[ -z "$counts" ]] && exit 0

      local ahead behind
      read -r ahead behind <<<"$counts"

      if ((behind > 0)); then
        local remote_sha
        remote_sha=$(git -C "$dotfiles_dir" rev-parse origin/main 2>/dev/null)

        local conflict_reason=""
        if ((ahead > 0)); then
          if ! git -C "$dotfiles_dir" merge-tree --write-tree HEAD origin/main >/dev/null 2>&1; then
            conflict_reason="merge conflict with local commits"
          fi
        fi

        if [[ -z "$conflict_reason" ]]; then
          local -a dirty_files remote_changes conflicts
          dirty_files=(${(f)"$(git -C "$dotfiles_dir" status --porcelain 2>/dev/null | sed -E 's/^...//')"})
          if ((${#dirty_files} > 0)); then
            remote_changes=(${(f)"$(git -C "$dotfiles_dir" diff --name-only HEAD..origin/main 2>/dev/null)"})
            conflicts=(${dirty_files:*remote_changes})
            if ((${#conflicts} > 0)); then
              conflict_reason="conflict in: ${(j:, :)conflicts}"
            fi
          fi
        fi

        local banner
        if [[ -n "$conflict_reason" ]]; then
          banner="%F{red}⚠️  Dotfiles has %B$behind%b new commit(s) upstream (%F{yellow}${conflict_reason}%F{red})! Check: %F{cyan}cd $dotfiles_dir && git status%f"
        else
          banner="%F{yellow}📦 Dotfiles has %B$behind%b new commit(s) upstream. Run: %F{cyan}cd $dotfiles_dir && git pull%f"
        fi

        # Write target_sha and banner to cache
        {
          print -r -- "$remote_sha"
          print -r -- "$banner"
        } >"$status_file"

        touch "$notify_file"

        # Signal the active interactive prompt to redraw with the fresh banner
        kill -USR1 "$parent_pid" 2>/dev/null
      else
        rm -f "$status_file" "$notify_file"
        unset _DOTFILES_NOTIFIED
      fi
    ) </dev/null >/dev/null 2>&1 &|
  fi
}

_check_dotfiles_update
