autoload -Uz compinit promptinit
compinit
promptinit

setopt noautomenu
setopt noautoremoveslash
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

setopt print_eight_bit
setopt no_beep
setopt ignore_eof
setopt no_flow_control

export HISTFILE=~/.zsh_history
export HISTSIZE=1000
export SAVEHIST=100000
setopt share_history
setopt hist_ignore_dups

export PROMPT="%B%F{green}%n❯❯%f%b %B%F{blue}%~%f%b
%B%F{green}❯%f%b "

precmd() { print "" }

if which dircolors >& /dev/null
then
  eval $(dircolors)
fi

if [ -n "$LS_COLORS" ]
then
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
fi

###############################################################################################

FZF_PLUGIN=/usr/share/fzf

if [ -d $FZF_PLUGIN ]
then
  source $FZF_PLUGIN/key-bindings.zsh
  source $FZF_PLUGIN/completion.zsh
  export FZF_DEFAULT_COMMAND="rg --files --follow --hidden 2> /dev/null"
  export FZF_DEFAULT_OPTS="--height 50% --layout=reverse --border --inline-info"
  export FZF_CTRL_T_COMMAND="locate -A ~"
  export FZF_CTRL_T_OPTS="--preview 'head -100 {} 2> /dev/null'"
fi

###############################################################################################

alias ls='ls --color'
alias ll='ls -al --time-style long-iso --color'
export LESS='-R'

if which nvim &> /dev/null
then
  alias vi='nvim'
  alias vim='nvim'
fi

if which xdg-open &> /dev/null
then
  alias open='xdg-open'
fi

###############################################################################################

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

export DEBUGINFOD_URLS=https://debuginfod.archlinux.org

###############################################################################################

if which tmux &> /dev/null && [ -z "$TMUX" ]
then
  tmux attach || tmux new-session
  exit 0
fi
