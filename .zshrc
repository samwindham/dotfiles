export ZSH="${HOME}/.oh-my-zsh"
ZSH_THEME="linuxonly"
plugins=(git-extras jj)

source "$ZSH/oh-my-zsh.sh"
[ -f "$HOME/.aliases" ] && source "$HOME/.aliases"

if command -v jj &> /dev/null; then
  source <(jj util completion zsh)
fi