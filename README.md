# dotfiles

Nothing to see here. Move along.

# Install

    cd ~
    git clone --recursive git@github.com:jpflouret/dotfiles.git
    ./dotfiles/install.sh -f

NOTE: Make sure the ssh keys for the machine are set in [GitHub](https://github.com/jpflouret)
otherwise the clone of submodles will fail. You'll need the ssh keys set
anyway if you intend to push any changes back to GitHub.

# Adding new files

    cd ~
    mv .my_dot_file ./dofiles/files/my_dot_file
    ./dotfiles/install .sh -f

