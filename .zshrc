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
  if command -v git >& /dev/null
  then
    local BRANCH="$(git branch --show-current 2> /dev/null)"
    [ -z "$BRANCH" ] && BRANCH="$(git show --format='%h' --no-patch 2> /dev/null)"
    [ -n "$BRANCH" ] && BRANCH="[$BRANCH]"
  fi

  export PROMPT="
%B%F{green}╭╴(%n$ATTMUX)%f%b %B%F{cyan}%~%f%b %B%F{red}$BRANCH%f%b
%B%F{green}╰╴\$%f%b "
}

function chpwd() {
  ls --color
}

if command -v dircolors >& /dev/null
then
  eval "$(dircolors 2> /dev/null)"
fi

if [ -n "$LS_COLORS" ]
then
  zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
fi

alias ls="ls --color"
alias ll="ls -al --time-style long-iso --color"
export LESS="-R"

###############################################################################################
if command -v mise &> /dev/null
then
  eval "$(mise activate zsh)"
fi

export EDITOR=vim
alias view='vim -R'

if command -v nvim &> /dev/null
then
  EDITOR=nvim
  alias vim=nvim
  alias view='nvim -R'
fi

if command -v xdg-open &> /dev/null
then
  alias open=xdg-open
fi

case $(grep -o -e Ubuntu -e EndeavourOS /etc/issue) in
  EndeavourOS) export DEBUGINFOD_URLS="https://debuginfod.archlinux.org";;
  Ubuntu) export DEBUGINFOD_URLS="https://debuginfod.ubuntu.com";;
esac

export FZF_DEFAULT_OPTS="--height 50% --layout=reverse --border --inline-info"
export FZF_DEFAULT_COMMAND="rg --files --follow --hidden 2> /dev/null"
export FZF_CTRL_T_COMMAND="locate -A ~ 2> /dev/null"
export FZF_CTRL_T_OPTS="--preview 'head -100 {} 2> /dev/null'"
source /usr/share/fzf/completion.zsh
source /usr/share/fzf/key-bindings.zsh
