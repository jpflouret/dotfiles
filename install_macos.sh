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


LN="ln -s"
[ $force -eq 0 ] || LN="$LN -f"
[ $dry_run -eq 0 ] || LN="echo $LN"

SYSNAME=`lowercase \`uname\``
case "$SYSNAME" in
  cygwin*)  SYSNAME=cygwin ;;
esac


[ -d $DST ] || mkdir $DST

for file in $DOTFILES/files/*; do
  source=`realpath --relative-to=$DST $file`
  target=`basename $file`
  $LN $source $DST/.$target
done

[ -d $DST/bin ] || mkdir $DST/bin
if [ -d $DOTFILES/bin ]; then
  for file in `find $DOTFILES/bin -maxdepth 1 -type f -print`; do
    source=`realpath --relative-to=$DST $file`
    target=`basename $file`
    $LN $source $DST/bin/$target
  done
fi

if [ -d $DOTFILES/bin/$SYSNAME ]; then
  for file in `find $DOTFILES/bin/$SYSNAME -type f -print`; do
    source=`realpath --relative-to=$DST $file`
    target=`basename $file`
    $LN $source $DST/bin/$target
  done
fi

# vim:ts=2:sw=2:et:tw=0:
