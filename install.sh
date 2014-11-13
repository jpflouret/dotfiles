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


LN="ln -s"
[ $force -eq 0 ] || LN="ln -sf"

SYSNAME=`lowercase \`uname\``
case "$SYSNAME" in
  cygwin*)  SYSNAME=cygwin ;;
esac


[ -d $DST ] || mkdir $DST

# Special case for vimfiles since it is a whole dir
if [ -d $DOTFILES/vimfiles ]; then
  $LN -T $DOTFILES/vimfiles $DST/.vim
  $LN -T .vim/vimrc $DST/.vimrc
  # On cygwin also create vimfiles in the user profile dir
  if [ $SYSNAME = "cygwin" ]; then
    $LN -T $DOTFILES/vimfiles $(cygpath $USERPROFILE)/vimfiles
  fi
fi

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

# vim:ts=2:sw=2:et:tw=0:
