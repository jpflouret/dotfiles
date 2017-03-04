#!/bin/bash


WHOAMI=$(whoami)
# Attempt to discover a detached session and attach
# it, else create a new session
if tmux has-session -t $WHOAMI 2>/dev/null; then
  exec tmux -2 attach-session -t $WHOAMI
else
  exec tmux -2 new-session -s $WHOAMI
fi

