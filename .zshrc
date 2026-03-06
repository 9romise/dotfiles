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

alias nu="nup"
alias mu="mise run upgrade"

function proxy() {
  export https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 all_proxy=socks5://127.0.0.1:7897
  echo "Proxy enabled"
}

function unproxy() {
  unset https_proxy http_proxy all_proxy
  echo "Proxy disabled"
}
