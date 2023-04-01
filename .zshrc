autoload -Uz compinit promptinit edit-command-line
compinit && promptinit

setopt noautomenu
setopt noautoremoveslash
setopt globdots
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

setopt print_eight_bit
setopt no_beep
setopt ignore_eof
setopt no_flow_control

export HISTFILE=~/.zsh_history
export HISTSIZE=100000
export SAVEHIST=100000
setopt share_history
setopt hist_ignore_all_dups
setopt hist_reduce_blanks

bindkey -e
zle -N edit-command-line
bindkey "^O" edit-command-line

if which xsel >& /dev/null
then
  function __copy() {
    xsel -pi && xsel -po | xsel -bi
  }

  function __paste() {
    xsel -bo
  }
fi

if which __copy __paste >& /dev/null
then
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
fi

precmd() {
  if [ -f '/.dockerenv' ]
  then
    local DOCKER="@docker"
    DOCKER="%B%F{red}$DOCKER%f%b"
  fi

  if which git >& /dev/null
  then
    local BRANCH="$(git branch --show-current 2> /dev/null)"
    [ -z "$BRANCH" ] && BRANCH="$(git show --format='%h' --no-patch 2> /dev/null)"
    [ -n "$BRANCH" ] && BRANCH="%B%F{red}[$BRANCH]%f%b"
  fi

  local NEWLINE=$'\n'
  export PROMPT=$NEWLINE
  export PROMPT=$PROMPT"%B%F{green}╭╴(%n$DOCKER)%f%b %B%F{cyan}%~%f%b $BRANCH"$NEWLINE
  export PROMPT=$PROMPT"%B%F{green}╰╴\$%f%b "
}

if which dircolors >& /dev/null
then
  eval "$(dircolors)"
fi

if [ -n "$LS_COLORS" ]
then
  zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
fi

alias ls="ls --color"
alias ll="ls -al --time-style long-iso --color"
export LESS="-R"

###############################################################################################

export EDITOR=vim

if which nvim &> /dev/null
then
  export EDITOR=nvim
  alias vim=nvim
fi

if which xdg-open &> /dev/null
then
  alias open=xdg-open
fi

if which docker &> /dev/null
then
  alias docker='sudo -E docker'
fi

export PATH=$PATH:/var/lib/snapd/snap/bin
export PATH=$PATH:~/bin
export PATH=$PATH:~/.local/bin
export PATH=$PATH:~/.cargo/bin:~/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin
export PATH=$PATH:~/go/bin
export PATH=$PATH:~/.local/share/gem/ruby/3.0.0/bin
export PATH=$PATH:~/perl5/bin
export PERL5LIB=~/perl5/lib/perl5
export PERL_LOCAL_LIB_ROOT=~/perl5
export PERL_MB_OPT="--install_base \"~/perl5\""
export PERL_MM_OPT="INSTALL_BASE=~/perl5"
export PATH=$PATH:/opt/idapro-8.2

export DEBUGINFOD_URLS=https://debuginfod.archlinux.org

###############################################################################################

[ -d /usr/share/fzf ] && FZF_PLUGIN=/usr/share/fzf
[ -d /usr/share/doc/fzf/examples ] && FZF_PLUGIN=/usr/share/doc/fzf/examples

if [ -n "$FZF_PLUGIN" ]
then
  source $FZF_PLUGIN/key-bindings.zsh
  source $FZF_PLUGIN/completion.zsh
  export FZF_DEFAULT_COMMAND="find . -type f -follow 2> /dev/null"
  export FZF_DEFAULT_OPTS="--height 50% --layout=reverse --border --inline-info"
  export FZF_CTRL_T_COMMAND="find ~ 2> /dev/null"
  export FZF_CTRL_T_OPTS="--preview 'head -100 {} 2> /dev/null'"

  if which rg &> /dev/null
  then
    export FZF_DEFAULT_COMMAND="rg --files --follow --hidden 2> /dev/null"
  fi

  if which locate &> /dev/null
  then
    export FZF_CTRL_T_COMMAND="locate -A ~"
  fi
fi

###############################################################################################

if which tmux &> /dev/null && [ -z "$TMUX" ] && [ ! -e "/.dockerenv" ]
then
  tmux attach || tmux new-session
  exit 0
fi
