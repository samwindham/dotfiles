export PATH="$PATH:$HOME/bin"

if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

# Add create-codespace script to path
chmod +x ~/dotfiles/bin/create-codespace
export PATH="$HOME/dotfiles/bin:$PATH"