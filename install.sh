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

# install Github CLI
install_gh_cli() {
  echo "🔧 Installing GitHub CLI..."

  if command -v gh &>/dev/null; then
    echo "✅ gh already installed"
    return
  fi

  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if command -v brew &>/dev/null; then
      brew install gh
    else
      echo "❌ Homebrew not found. Please install it first."
    fi

  elif [[ -f "/etc/debian_version" ]]; then
    # Debian/Ubuntu
    type -p curl >/dev/null || sudo apt install curl -y
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
      sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
      https://cli.github.com/packages stable main" | \
      sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install gh -y

  else
    echo "⚠️ Unsupported OS. Please install gh manually: https://cli.github.com/manual/installation"
  fi
}

install_gh_cli

# install github extension
gh extension install stacked-gh/gh-stack