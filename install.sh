#!/bin/sh

DST=$HOME
DOTFILES=`readlink -en \`dirname $0\``

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
}


force=0
while getopts "h?f" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    f)  force=1
        ;;
    esac
done


LN="ln -sT"
[ $force -eq 0 ] || LN="ln -sfT"

SYSNAME=`lowercase \`uname\``
case "$SYSNAME" in
  cygwin*)  SYSNAME=cygwin ;;
esac


[ -d $DST ] || mkdir $DST

for file in $DOTFILES/files/*; do
  target=`basename $file`
  $LN $file $DST/.$target
done

[ -d $DST/bin ] || mkdir $DST/bin
for file in `find $DOTFILES/bin -maxdepth 1 -type f -print`; do
  target=`basename $file`
  $LN $file $DST/bin/$target
done

if [ -d $DOTFILES/bin/$SYSNAME ]; then
  for file in `find $DOTFILES/bin/$SYSNAME -type f -print`; do
    target=`basename $file`
    $LN $file $DST/bin/$target
  done
fi

# -- Special cases --

# Vim: also link .vimrc ro .vim/vimrc for vim < 7.4
[ -d $DST/.vim ] && $LN .vim/vimrc $DST/.vimrc

# On cygwin also create vimfiles in the user profile dir
if [ $SYSNAME = "cygwin" ]; then
  $LN $DOTFILES/files/vim $(cygpath $USERPROFILE)/vimfiles
fi

# vim:ts=2:sw=2:et:tw=0:
