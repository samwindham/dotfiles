#!/bin/bash

create_symlinks() {
    script_dir=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)

    for obsolete in .blerc .atuin_key .atuin_session; do
        [ -L "$HOME/$obsolete" ] && rm -f "$HOME/$obsolete"
    done

    for file in "$script_dir"/.*; do
        [ -f "$file" ] || continue
        name=$(basename "$file")
        [ "$name" = ".gitignore" ] && continue
        echo "Creating symlink: ~/$name -> $file"
        rm -rf ~/"$name"
        ln -s "$file" ~/"$name"
    done

    mkdir -p "$HOME/.config/git" "$HOME/.config/jj"
    ln -sf "$script_dir/.config/git/config" "$HOME/.config/git/config"
    ln -sf "$script_dir/.config/jj/config.toml" "$HOME/.config/jj/config.toml"
}

create_symlinks

# Install jj (Jujutsu) if not already installed
if ! command -v jj &> /dev/null; then
  echo "Installing jj (Jujutsu)..."
  JJ_VERSION="0.39.0"  # Update as needed: https://github.com/jj-vcs/jj/releases
  curl -sL "https://github.com/jj-vcs/jj/releases/download/v${JJ_VERSION}/jj-v${JJ_VERSION}-x86_64-unknown-linux-musl.tar.gz" -o /tmp/jj.tar.gz
  tar xzf /tmp/jj.tar.gz -C /tmp
  mkdir -p "$HOME/bin"
  mv /tmp/jj "$HOME/bin/jj"
  chmod +x "$HOME/bin/jj"
  rm -f /tmp/jj.tar.gz
  echo "✅ jj installed"
fi
