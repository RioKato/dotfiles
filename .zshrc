autoload -Uz compinit promptinit
compinit && promptinit

setopt noautomenu
setopt noautoremoveslash
setopt globdots
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

setopt print_eight_bit
setopt no_beep
setopt no_flow_control

export HISTFILE=~/.zsh_history
export HISTSIZE=100000
export SAVEHIST=100000
setopt share_history
setopt hist_ignore_all_dups
setopt hist_reduce_blanks

bindkey -e

function __copy() {
  xsel -pi && xsel -po | xsel -bi
}

function __paste() {
  xsel -bo
}

function __kill-line() {
  zle kill-line
  echo -n "$CUTBUFFER" | __copy
}

function __backward-kill-line() {
  zle backward-kill-line
  echo -n "$CUTBUFFER" | __copy
}

function __yank() {
  CUTBUFFER="$(__paste)"
  zle yank
}

zle -N __kill-line
zle -N __backward-kill-line
zle -N __yank
bindkey '^k' __kill-line
bindkey '^u' __backward-kill-line
bindkey '^y' __yank

function precmd() {
  local BRANCH="$(git branch --show-current 2> /dev/null)"

  if [ -n "$BRANCH" ]
  then
    BRANCH="[$BRANCH]"
  fi

  export PROMPT="
%B%F{green}╭╴(%n)%f%b %B%F{cyan}%~%f%b %B%F{red}$BRANCH%f%b
%B%F{green}╰╴\$%f%b "
}

function chpwd() {
  ls --color
}

eval "$(dircolors 2> /dev/null)"
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

alias ls="ls --color"
alias ll="ls -al --time-style long-iso --color"
export LESS="-R"

###############################################################################################
eval "$(mise activate zsh)"

export EDITOR=nvim
alias vim=nvim
alias view='nvim -R'
alias open=xdg-open

export FZF_DEFAULT_OPTS="--height 50% --layout=reverse --border --inline-info"
export FZF_DEFAULT_COMMAND="rg --files --follow --hidden 2> /dev/null"
export FZF_CTRL_T_COMMAND="locate -A ~ 2> /dev/null"
export FZF_CTRL_T_OPTS="--preview 'head -100 {} 2> /dev/null'"
source /usr/share/fzf/completion.zsh
source /usr/share/fzf/key-bindings.zsh

###############################################################################################
export XDG_CONFIG_HOME=~/.config
export DOCKER_CONFIG=$XDG_CONFIG_HOME/docker
alias mitmproxy="mitmproxy --set confdir=$XDG_CONFIG_HOME/mitmproxy"
alias mitmweb="mitmweb --set confdir=$XDG_CONFIG_HOME/mitmproxy"
