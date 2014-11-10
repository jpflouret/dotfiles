
# vi: ts=2 sw=2 tw=80 et

case "$(uname)" in
   CYGWIN*) cygwin=1 ;;
   *)       cygwin=0 ;;
esac

if [ $cygwin ]; then
  # Exporting PWD in cygwin usually breaks other programs that use PWD but don't
  # understand cygwin paths.
  export -n PWD
fi

# Add user's bin folder
if [ -d ~/bin ]; then
  export PATH=~/bin:$PATH
fi

# Add current dir to path
#export PATH=.:$PATH

# set -o notify
# set -o ignoreeof
shopt -s nocaseglob
shopt -s histappend
shopt -s cdspell

# If this shell is interactive, turn on programmable completion enhancements.
case $- in
  *i*)
    [[ -f /etc/bash_completion ]] && . /etc/bash_completion
    ;;
esac

#export PROMPT_DIRTRIM=5
export PS1=
#export PS1=${PS1}'\[\e[0m\]\n'         # newline
export PS1=${PS1}'\[\e[34;1m\][\t]'     # time
export PS1=${PS1}'\[\e[32m\][\u@\h]'    # user@host
export PS1=${PS1}'\[\e[33;1m\][\w]'     # working dir
export PS1=${PS1}'\[\e[0m\] \$ '        # $

export HISTCONTROL="ignoreboth"
export HISTIGNORE=$'[ \t]*:&:[fb]g:exit'

g() {
  if [ -z "$(command vim --serverlist)" ]; then
    command gvim "$@"
  else
    command gvim --remote-silent "$@" ;
  fi
}

alias df='df -h'
alias du='du -h'
alias grep='grep --color'
alias ls='ls -hF --color=tty'
alias dir='ls --color=auto --format=vertical'
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias vim=g
alias vi=g

