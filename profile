#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
# done this in bashrc because of cygwin
# if [ -d "$HOME/bin" ] ; then
#     PATH="$HOME/bin:$PATH"
# fi
