alias vi='nvim'
alias vim='nvim'

export PATH=$PATH:~/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin
export PATH=$PATH:/usr/local/go/bin:~/go/bin
export PATH=$PATH:~/.local/share/gem/ruby/3.0.0/bin

export FZF_DEFAULT_OPTS="--height 50% --layout=reverse --border --inline-info"
export FZF_CTRL_T_COMMAND="locate -A /"
export FZF_CTRL_T_OPTS="--preview 'head -100 {}'"
source /usr/share/doc/fzf/examples/key-bindings.bash
