#!/bin/bash

create_symlinks() {
    # Get the directory in which this script lives.
    script_dir=$(dirname "$(readlink -f "$0")")

    # Get a list of all files in this directory that start with a dot.
    files=$(find -maxdepth 1 -type f -name ".*")

    # Create a symbolic link to each file in the home directory.
    for file in $files; do
        name=$(basename $file)
        echo "Creating symlink to $name in home directory."
        rm -rf ~/$name
        ln -s $script_dir/$name ~/$name
    done

    ln -s "$script_dir/.config/atuin" "$HOME/.config/atuin"
}

create_symlinks


mkdir -p "$HOME/bin"
wget https://github.com/atuinsh/atuin/releases/latest/download/atuin-x86_64-unknown-linux-gnu.tar.gz
tar xvf - atuin-x86_64-unknown-linux-gnu.tar.gz
cp atuin-x86_64-unknown-linux-gnu/atuin "$HOME/bin/atuin"

wget https://github.com/akinomyoga/ble.sh/releases/download/v0.3.4/ble-0.3.4.tar.xz 
tar xvf - ble-0.3.4.tar.xz
bash ble-0.3.4/ble.sh --install "$HOME/.local/share/"

bash "$HOME"/.local/share/blesh/ble.sh --update 

printf "%s" "$ATUIN_SESSION" > "$HOME/.atuin_session"
printf "%s" "$ATUIN_KEY" > "$HOME/.atuin_key"

unset ATUIN_KEY