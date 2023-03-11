SUGGESTIONS_PATH=/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
FZF_PATH=/usr/share/fzf/key-bindings.zsh

if [ -e $SUGGESTIONS_PATH ]
then
  source $SUGGESTIONS_PATH
  export ZSH_AUTOSUGGEST_STRATEGY=(completion)
fi

if [ -e $FZF_PATH ]
then
  source $FZF_PATH
  export FZF_DEFAULT_OPTS="--height 50% --layout=reverse --border --inline-info"
  export FZF_CTRL_T_COMMAND="locate -A /"
  export FZF_CTRL_T_OPTS="--preview 'head -100 {} 2> /dev/null'"
fi

autoload -Uz compinit promptinit
compinit
promptinit

setopt print_eight_bit
setopt no_beep
unsetopt auto_menu
setopt no_flow_control

export HISTFILE=${HOME}/.zsh_history
export HISTSIZE=1000
export SAVEHIST=100000
setopt share_history
setopt hist_ignore_dups

PROMPT="%B%F{green}%n❯❯%f%b %B%F{blue}%~%f%b
%B%F{green}❯%f%b "

precmd() { print "" }

###############################################################################################

export PATH=$PATH:/var/lib/snapd/snap/bin
export PATH=$PATH:~/bin
export PATH=$PATH:~/.local/bin
export PATH=$PATH:~/.cargo/bin:~/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin
export PATH=$PATH:~/go/bin
export PATH=$PATH:~/.local/share/gem/ruby/3.0.0/bin

export DEBUGINFOD_URLS=https://debuginfod.archlinux.org

alias ls='ls --color=auto'
alias ll='ls -alt --color=auto'
alias vi='nvim'
alias vim='nvim'
