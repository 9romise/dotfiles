# oh-my-zsh
# sh -c "$(curl -fsSL https://install.ohmyz.sh)"
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


function proxy() {
    export http_proxy=http://127.0.0.1:7897
    export https_proxy=http://127.0.0.1:7897
    echo -e "终端代理已开启。"
}

function unproxy(){
    unset http_proxy https_proxy
    echo -e "终端代理已关闭。"
}
