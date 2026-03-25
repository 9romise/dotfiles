# zim
# https://github.com/zimfw/zimfw
ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
# Install missing modules and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source /opt/homebrew/opt/zimfw/share/zimfw.zsh init
fi
# Initialize modules.
source ${ZIM_HOME}/init.zsh

# starship
eval "$(starship init zsh)"
# mise
eval "$(mise activate zsh)"

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
