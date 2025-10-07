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
# MANUALLY INSTALLED TOOLS
###################################

if [[ "$os" == "Linux" ]]; then
  . "$HOME/.local/share/../bin/env"
fi

###################################
# ENV
###################################
export EDITOR='nvim'
export SUDO_EDITOR="$EDITOR"
export ZVM_VI_EDITOR="$EDITOR"
export ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
export PATH="$HOME/.tmuxifier/bin:$PATH"
# export ZVM_SYSTEM_CLIPBOARD_ENABLED=true


###################################
# EVAL
###################################
eval "$(tmuxifier init -)"
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

alias nvdir='cd ~/.config/nvim'
if [[ "$os" == "Darwin" ]]; then
  alias pydir='function _pydir(){ cd ~/Documents/programming/python/"$1"; }; _pydir'
else
  alias pydir='function _pydir(){ cd ~/Projects/python/"$1"; }; _pydir'
fi

alias runcpp='function _runcpp(){ g++ "$1" -o main && ./main; }; _runcpp'

alias c='clear'
alias nv='nvim'
alias ls='eza -l --icons=always'
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
