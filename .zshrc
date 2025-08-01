# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="spaceship"
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)
# https://ohmyz.sh/
source $ZSH/oh-my-zsh.sh

# nvm
# brew install nvm
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# corepack
export COREPACK_NPM_REGISTRY="https://registry.npmmirror.com"

alias nu="nup"
