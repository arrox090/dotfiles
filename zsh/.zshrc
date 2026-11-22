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
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

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
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
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

    cat > "/tmp/$file" <<EOF
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

alias runcpp='function _runcpp(){ g++ "$1" -o main && ./main; }; _runcpp'

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
  local orig_buffer=$BUFFER     # save what was typed
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

function bind_keys_after_everything() {
  bindkey -v
  bindkey -r '^L'
  bindkey -r '^K'
  bindkey -r '^J'
  bindkey -r '^H'
  bindkey -r '^R' 
  bindkey '^R' fzf-history-widget
}

add-zsh-hook precmd bind_keys_after_everything

###################################
# OPTIONS
###################################
setopt CORRECT

# Make auto complete case insensitive
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

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
setopt INC_APPEND_HISTORY      # save after each command
setopt SHARE_HISTORY           # share history across terminals
setopt HIST_IGNORE_DUPS        # ignore consecutive duplicates
setopt HIST_REDUCE_BLANKS      # strip the command string


###################################
# STARSHIP DOUBLE WRAPPING AFTER SOURCING FIX
###################################
if [[ -z ${functions[starship_zle-keymap-select-wrapped]+x} ]]; then
  functions[starship_zle-keymap-select-wrapped]=$functions[zle-keymap-select]
  zle -N zle-keymap-select starship_zle-keymap-select
fi



alias nvim-lazy='NVIM_APPNAME="nvim-lazyvim" nvim'
# rm -rf ~/.config/nvim-lazyvim ~/.local/share/nvim-lazyvim ~/.cache/nvim-lazyvim ~/.local/state/nvim-lazyvim

alias nvim-nvchad='NVIM_APPNAME="nvim-nvchad" nvim'
# rm -rf ~/.config/nvim-nvchad ~/.local/share/nvim-nvchad ~/.cache/nvim-nvchad ~/.local/state/nvim-nvchad

alias nvim-astro='NVIM_APPNAME="nvim-astronvim" nvim'
# rm -rf ~/.config/nvim-astronvim ~/.local/share/nvim-astronvim ~/.cache/nvim-astronvim ~/.local/state/nvim-astronvim

###################################
# DOTFILES UPDATE CHECK (Debounced 6h)
###################################
_check_dotfiles_update() {
  local dotfiles_dir
  if [[ "$os" == "Darwin" ]]; then
    dotfiles_dir="$HOME/dotfiles"
  else
    dotfiles_dir="$HOME/projects/dotfiles"
  fi

  [[ -d "$dotfiles_dir/.git" ]] || return

  zmodload zsh/datetime 2>/dev/null
  local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}"
  local stamp="$cache_dir/dotfiles_last_check"
  local now=$EPOCHSECONDS
  local last_check=0

  [[ -f "$stamp" ]] && read -r last_check < "$stamp"

  # 1. Background fetch every 6 hours (21600 seconds)
  if (( now - last_check > 21600 )); then
    mkdir -p "$cache_dir"
    echo "$now" > "$stamp"
    ( git -C "$dotfiles_dir" fetch -q origin main 2>/dev/null ) &!
  fi

  # 2. Check ahead/behind counts against origin/main
  local counts
  counts=$(git -C "$dotfiles_dir" rev-list --left-right --count HEAD...origin/main 2>/dev/null)
  [[ -z "$counts" ]] && return

  local ahead behind
  read -r ahead behind <<< "$counts"

  if (( behind > 0 )); then
    local conflict_reason=""

    # Check A: Diverged commits conflict (ahead > 0 and behind > 0)
    if (( ahead > 0 )); then
      if ! git -C "$dotfiles_dir" merge-tree --write-tree HEAD origin/main >/dev/null 2>&1; then
        conflict_reason="merge conflict with local commits"
      fi
    fi

    # Check B: Uncommitted local changes colliding with incoming changes
    if [[ -z "$conflict_reason" ]]; then
      local -a dirty_files remote_changes conflicts
      dirty_files=(${(f)"$(git -C "$dotfiles_dir" status --porcelain 2>/dev/null | sed -E 's/^...//')"})
      if (( ${#dirty_files} > 0 )); then
        remote_changes=(${(f)"$(git -C "$dotfiles_dir" diff --name-only HEAD..origin/main 2>/dev/null)"})
        conflicts=(${dirty_files:*remote_changes})
        if (( ${#conflicts} > 0 )); then
          conflict_reason="conflict in: ${(j:, :)conflicts}"
        fi
      fi
    fi

    # 3. Print clean notification banner
    if [[ -n "$conflict_reason" ]]; then
      print -P "%F{red}⚠️  Dotfiles has %B$behind%b new commit(s) upstream (%F{yellow}${conflict_reason}%F{red})! Check: %F{cyan}cd
      $dotfiles_dir && git status%f"
    else
      print -P "%F{yellow}📦 Dotfiles has %B$behind%b new commit(s) upstream. Run: %F{cyan}cd $dotfiles_dir && git pull%f"
    fi
  fi
}

_check_dotfiles_update
