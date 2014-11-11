
# vi: ts=2 sw=2 tw=80 et

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

case "$(uname)" in
   CYGWIN*) cygwin=1 ;;
   *)       cygwin=0 ;;
esac

if [ $cygwin ]; then
  # Exporting PWD in cygwin usually breaks other programs
  # that use PWD but don't understand cygwin paths.
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
shopt -s checkwinsize
shopt -s globstar

# bash completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# history control
HISTSIZE=1000
HISTFILESIZE=2000
HISTCONTROL="ignoreboth"
HISTIGNORE=$'[ \t]*:&:[fb]g:exit'

# use lesspipe if available
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set debian_chroot if available
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

PS1=
#PS1=${PS1}'\[\e[0m\]\n'         # newline
PS1=${PS1}'${debian_chroot:+($debian_chroot)}'
PS1=${PS1}'\[\e[34;1m\][\t]'     # time
PS1=${PS1}'\[\e[32m\][\u@\h]'    # user@host
PS1=${PS1}'\[\e[33;1m\][\w]'     # working dir
PS1=${PS1}'\[\e[0m\] \$ '        # $

# Set the xterm title
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

export NCURSES_NO_UTF8_ACS=1

# gvim shortcut that uses remote vim when available
g() {
  if [ -z "$(command vim --serverlist)" ]; then
    command gvim "$@"
  else
    command gvim --remote-silent "$@" ;
  fi
}

# enable color support
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls -F --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias df='df -h'
alias du='du -h'
alias ll='ls -lF'
alias la='ls -AF'
alias l='ls -CF'

alias vim=g
alias vi=g

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

set -o vi
