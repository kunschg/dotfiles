export PATH="/opt/homebrew/bin:$PATH"

eval "$(starship init bash)"
source ~/.local/share/blesh/ble.sh # if slow run complete -r -> https://github.com/akinomyoga/ble.sh/issues/58

# Enable bash completion
if [[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]]; then
  source "/opt/homebrew/etc/profile.d/bash_completion.sh"
fi

source ~/.aliases
