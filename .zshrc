# zim (zsh plugin manager)
ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source /opt/homebrew/opt/zimfw/share/zimfw.zsh init
fi
source ${ZIM_HOME}/init.zsh

# starship prompt
eval "$(starship init zsh)"

# mise (dev tools version manager)
eval "$(mise activate zsh)"

# aliases
alias nu="nup"
alias mu="mise run upgrade"
