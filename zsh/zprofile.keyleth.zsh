eval "$(/opt/homebrew/bin/brew shellenv)"
export HOMEBREW_DISPLAY_INSTALL_TIMES=1
export HOMEBREW_KEEP_OUTPUT=1

# Adds things like coreutils to PATH.
source "$HOME/.config/zsh/zprofile.macos.zsh"

export PATH="$PATH:/opt/homebrew-rosetta/bin"

export XDG_CACHE_HOME="/Users/qyriad/.cache"
export XDG_CONFIG_HOME="/Users/qyriad/.config"
export XDG_DATA_HOME="/Users/qyriad/.local/share"

export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
