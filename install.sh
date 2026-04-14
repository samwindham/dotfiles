#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

create_symlinks() {
    for obsolete in .blerc .atuin_key .atuin_session; do
        [ -L "$HOME/$obsolete" ] && rm -f "$HOME/$obsolete"
    done

    for file in "$DOTFILES_DIR"/.*; do
        [ -f "$file" ] || continue
        name=$(basename "$file")
        [ "$name" = ".gitignore" ] && continue
        echo "Creating symlink: ~/$name -> $file"
        rm -rf ~/"$name"
        ln -s "$file" ~/"$name"
    done

    mkdir -p "$HOME/.config/git" "$HOME/.config/jj"
    ln -sf "$DOTFILES_DIR/.config/git/config" "$HOME/.config/git/config"
    ln -sf "$DOTFILES_DIR/.config/jj/config.toml" "$HOME/.config/jj/config.toml"
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

# Colocate jj with the dev workspace under /workspaces/ (Ona: usually a single
# checkout). First directory with a .git wins. Override with DEV_WORKSPACE_ROOT.
PATH="${HOME}/bin:${PATH}"
resolve_dev_workspace() {
  if [ -n "${DEV_WORKSPACE_ROOT:-}" ] && [ -d "${DEV_WORKSPACE_ROOT}/.git" ]; then
    printf '%s' "$DEV_WORKSPACE_ROOT"
    return
  fi
  if [ ! -d /workspaces ]; then
    return
  fi
  local d
  for d in /workspaces/*; do
    [ -d "$d" ] || continue
    [ -d "$d/.git" ] || continue
    printf '%s' "$d"
    return
  done
}

DEV_WORKSPACE="$(resolve_dev_workspace)"
if [ -n "$DEV_WORKSPACE" ]; then
  if command -v jj >/dev/null 2>&1; then
    if [ ! -d "$DEV_WORKSPACE/.jj" ]; then
      echo "Running jj git init in $DEV_WORKSPACE..."
      (cd "$DEV_WORKSPACE" && jj git init)
    fi
  else
    echo "Skipping jj git init: jj not on PATH (ensure $HOME/bin is in PATH)" >&2
  fi
fi

# Install mergiraf if not already installed
# https://codeberg.org/mergiraf/mergiraf/releases
if ! command -v mergiraf &> /dev/null; then
  echo "Installing mergiraf..."
  MERGIRAF_VERSION="0.16.3"
  mkdir -p "$HOME/bin"
  kernel=$(uname -s)
  machine=$(uname -m)
  case "$machine" in
    arm64) machine=aarch64 ;;
  esac
  asset=""
  if [ "$kernel" = "Linux" ]; then
    case "$machine" in
      x86_64) asset="mergiraf_x86_64-unknown-linux-gnu.tar.gz" ;;
      aarch64) asset="mergiraf_aarch64-unknown-linux-gnu.tar.gz" ;;
      *)
        echo "Unsupported Linux architecture: $machine" >&2
        exit 1
        ;;
    esac
  elif [ "$kernel" = "Darwin" ]; then
    case "$machine" in
      x86_64) asset="mergiraf_x86_64-apple-darwin.tar.gz" ;;
      aarch64) asset="mergiraf_aarch64-apple-darwin.tar.gz" ;;
      *)
        echo "Unsupported Darwin architecture: $machine" >&2
        exit 1
        ;;
    esac
  else
    echo "Unsupported OS for mergiraf install: $kernel" >&2
    exit 1
  fi
  tmpdir=$(mktemp -d)
  url="https://codeberg.org/mergiraf/mergiraf/releases/download/v${MERGIRAF_VERSION}/${asset}"
  curl -sL "$url" -o "$tmpdir/mergiraf.tar.gz"
  tar xzf "$tmpdir/mergiraf.tar.gz" -C "$tmpdir"
  mv "$tmpdir/mergiraf" "$HOME/bin/mergiraf"
  chmod +x "$HOME/bin/mergiraf"
  rm -rf "$tmpdir"
  echo "✅ mergiraf installed"
fi

mkdir -p "$HOME/.local/state"
touch "$HOME/.local/state/dotfiles-install.stamp"
