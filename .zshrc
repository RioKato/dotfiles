SUGGESTIONS_PATH=/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
HIGHLIGHTING_PATH=/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
POWERLEVEL10K_PATH=/usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
FZF_PATH=/usr/share/fzf/key-bindings.zsh

if [ -e $SUGGESTIONS_PATH ]
then
  source $SUGGESTIONS_PATH
  export ZSH_AUTOSUGGEST_STRATEGY=(completion)
fi

if [ -e $HIGHLIGHTING_PATH ]
then
  source $HIGHLIGHTING_PATH
fi

if [ -e $POWERLEVEL10K_PATH ]
then
  source $POWERLEVEL10K_PATH
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
fi

if [ -e $FZF_PATH ]
then
  source $FZF_PATH

  export FZF_DEFAULT_OPTS="--height 50% --layout=reverse --border --inline-info"
  export FZF_CTRL_T_COMMAND="locate -A /"
  export FZF_CTRL_T_OPTS="--preview 'head -100 {} 2> /dev/null'"
fi

autoload -Uz compinit promptinit colors
compinit
promptinit
colors

setopt print_eight_bit
setopt no_beep

export PATH=$PATH:~/bin
export PATH=$PATH:/var/lib/snapd/snap/bin
export PATH=$PATH:~/.local/bin
export PATH=$PATH:~/.cargo/bin:~/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin
export PATH=$PATH:~/go/bin
export PATH=$PATH:~/.local/share/gem/ruby/3.0.0/bin

export DEBUGINFOD_URLS=https://debuginfod.archlinux.org

alias vi='nvim'
alias vim='nvim'
