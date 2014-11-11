
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
set -o vi
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

# prompt settings
PROMPT_COMMAND="history -a; history -c; history -r;$PROMPT_COMMAND"
PROMPT_DIRTRIM=5

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
  if [ -z "$(which gvim)" ]; then
    vim "$@"
  else
    if [ -z "$(command vim --serverlist)" ]; then
      command gvim "$@"
    else
      command gvim --remote-silent "$@" ;
    fi
  fi
}

alias v=vim

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

alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# run a tmux session
if [ -x /usr/bin/tmux ]; then
  if [ "$TERM" != "screen" ] && [ "$SSH_CONNECTION" == "" ]; then
    # Attempt to discover a detached session and attach
    # it, else create a new session

    WHOAMI=$(whoami)
    if tmux has-session -t $WHOAMI 2>/dev/null; then
      exec tmux -2 attach-session -t $WHOAMI
    else
      exec tmux -2 new-session -s $WHOAMI
    fi
  fi
fi
