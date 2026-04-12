#!/bin/bash

#set -x

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
DST=$HOME
DOTFILES=$SCRIPT_DIR

if [ -z "$CYGWIN" ]; then
  export CYGWIN=winsymlinks:native
fi

lowercase(){
    echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

show_help() {
  echo "$0 [-f] [-h]"
  echo "  -f    Force overwrite"
  echo "  -h    Show this help"
  echo "  -n    Dry run (echo commands)"
}

force=0
dry_run=0
while getopts "h?fn" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    f)  force=1
        ;;
    n)  dry_run=1
        ;;
    esac
done


LN=(ln -s)
[ "$force" -eq 0 ] || LN+=(-f)

link_file() {
  if [ "$dry_run" -eq 0 ]; then
    "${LN[@]}" "$1" "$2"
  else
    printf '%q ' "${LN[@]}" "$1" "$2"
    printf '\n'
  fi
}

SYSNAME=$(lowercase "$(uname)")
case "$SYSNAME" in
  cygwin*)  SYSNAME=cygwin ;;
esac


[ -d "$DST" ] || mkdir "$DST"

for file in "$DOTFILES"/files/*; do
  link_source=$(grealpath --relative-to="$DST" "$file")
  target=$(basename "$file")
  link_file "$link_source" "$DST/.$target"
done

# Migrate old .gitconfig.local to .gitconfig.d/local
if [ -f "$DST/.gitconfig.local" ]; then
  mv "$DST/.gitconfig.local" "$DST/.gitconfig.d/local"
fi

[ -d "$DST/bin" ] || mkdir "$DST/bin"
if [ -d "$DOTFILES/bin" ]; then
  while IFS= read -r -d '' file; do
    link_source=$(grealpath --relative-to="$DST" "$file")
    target=$(basename "$file")
    link_file "$link_source" "$DST/bin/$target"
  done < <(find "$DOTFILES/bin" -maxdepth 1 -type f -print0)
fi

if [ -d "$DOTFILES/bin/$SYSNAME" ]; then
  while IFS= read -r -d '' file; do
    link_source=$(grealpath --relative-to="$DST" "$file")
    target=$(basename "$file")
    link_file "$link_source" "$DST/bin/$target"
  done < <(find "$DOTFILES/bin/$SYSNAME" -type f -print0)
fi

# vim:ts=2:sw=2:et:tw=0:
