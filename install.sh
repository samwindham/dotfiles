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
tar xvf atuin-x86_64-unknown-linux-gnu.tar.gz
cp atuin-x86_64-unknown-linux-gnu/atuin "$HOME/bin/atuin"

wget https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly.tar.xz 
tar xvf ble-nightly.tar.xz
chmod +x ble-nightly/ble.sh
bash ble-nightly/ble.sh --install "$HOME/.local/share/"

bash "$HOME"/.local/share/blesh/ble.sh --update 

printf "%s" "$ATUIN_SESSION" > "$HOME/.atuin_session"
printf "%s" "$ATUIN_KEY" > "$HOME/.atuin_key"

unset ATUIN_KEY

pip install git-machete
git config machete.github.forceDescriptionFromCommitMessage true

source "$HOME/.bashrc"

# Install fzf if it's not already installed
if ! command -v fzf &> /dev/null; then
  echo "Installing fzf..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install fzf
  elif [[ -x "$(command -v apt-get)" ]]; then
    sudo apt-get update && sudo apt-get install -y fzf
  else
    echo "Please install fzf manually for your system"
  fi
fi

# Install jj
sudo apt-get install build-essential
cargo install --locked --bin jj jj-cli