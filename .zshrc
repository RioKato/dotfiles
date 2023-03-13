SUGGESTIONS_PATH=/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
FZF_DIR_PATH=/usr/share/fzf

if [ -e "$SUGGESTIONS_PATH" ]
then
  source $SUGGESTIONS_PATH
  export ZSH_AUTOSUGGEST_STRATEGY=(completion)
fi

if [ -d "$FZF_DIR_PATH" ]
then
  source $FZF_DIR_PATH/key-bindings.zsh
  source $FZF_DIR_PATH/completion.zsh
  export FZF_DEFAULT_COMMAND="rg --files --follow --hidden 2> /dev/null"
  export FZF_DEFAULT_OPTS="--height 50% --layout=reverse --border --inline-info"
  export FZF_CTRL_T_COMMAND="locate -A ~"
  export FZF_CTRL_T_OPTS="--preview 'head -100 {} 2> /dev/null'"
fi

autoload -Uz compinit promptinit
compinit
promptinit

setopt print_eight_bit
setopt no_beep
unsetopt auto_menu
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

###############################################################################################

alias ls='ls --color=auto'
alias ll='ls -al --time-style long-iso --color=auto'
alias open='xdg-open'
alias vi='nvim'
alias vim='nvim'

export PATH=$PATH:/var/lib/snapd/snap/bin
export PATH=$PATH:~/bin
export PATH=$PATH:~/.local/bin
export PATH=$PATH:~/.cargo/bin:~/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin
export PATH=$PATH:~/go/bin
export PATH=$PATH:~/.local/share/gem/ruby/3.0.0/bin

export DEBUGINFOD_URLS=https://debuginfod.archlinux.org

###############################################################################################

if which tmux &> /dev/null && [ -z "$TMUX" ]
then
  tmux attach || tmux new-session
  exit 0
fi
