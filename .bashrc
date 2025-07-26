export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"

. "$HOME/.local/bin/env"

eval "$(starship init bash)"
source ~/.local/share/blesh/ble.sh

# Enable bash completion
if [[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]]; then
  source "/opt/homebrew/etc/profile.d/bash_completion.sh"
fi

source ~/.aliases
