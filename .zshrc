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

alias clang='clang -MJ compile_commands.json'
alias gcc-cov='gcc -coverage'
alias clang-cov='clang -fprofile-instr-generate -fcoverage-mapping'
alias git-pclone='git clone --filter=blob:none -n'
alias gcc-nodep='musl-gcc -std=c++20 -fmodules-ts -nodefaultlibs -lc -nostdinc++ -fno-exceptions -fno-rtti'
alias rrrecord='rr record --bind-to-cpu=0'
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
export PYTHONPATH=$PYTHONPATH:/opt/idapro-8.2/python/3
export PATH=$PATH:~/binaryninja

###############################################################################################
if command -v fzf >& /dev/null
then
  export FZF_DEFAULT_COMMAND="find . -type f -follow 2> /dev/null"
  export FZF_DEFAULT_OPTS="--height 50% --layout=reverse --border --inline-info"

  if command -v rg &> /dev/null
  then
    FZF_DEFAULT_COMMAND="rg --files --follow --hidden 2> /dev/null"
  fi
fi

[ -d /usr/share/fzf ] && FZF_PLUGIN=/usr/share/fzf
[ -d /usr/share/doc/fzf/examples ] && FZF_PLUGIN=/usr/share/doc/fzf/examples

if [ -n "$FZF_PLUGIN" ]
then
  if [ -e "$FZF_PLUGIN/completion.zsh" ]
  then
    source "$FZF_PLUGIN/completion.zsh"
  fi

  if [ -e "$FZF_PLUGIN/key-bindings.zsh" ]
  then
    source "$FZF_PLUGIN/key-bindings.zsh"
    export FZF_CTRL_T_COMMAND="find ~ 2> /dev/null"
    export FZF_CTRL_T_OPTS="--preview 'head -100 {} 2> /dev/null'"

    if command -v locate &> /dev/null
    then
      FZF_CTRL_T_COMMAND="locate -A ~ 2> /dev/null"
    fi
  fi
fi

###############################################################################################
export PATH=$PATH:"/mnt/c/Windows/System32"
export PATH=$PATH:"/mnt/c/Windows/System32/WindowsPowerShell/v1.0"
export PATH=$PATH:"/mnt/c/Program Files (x86)/Windows Kits/10/Debugger/x64"
export PATH=$PATH:"/mnt/c/Program Files (x86)/Microsoft Visual Studio/2022/BuildTools/VC/Tools/MSVC/14.39.33519/bin/Hostx64/x64"
export PATH=$PATH:"/mnt/c/Program Files (x86)/Microsoft Visual Studio/2022/BuildTools/MSBuild/Current/Bin"
