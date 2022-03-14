eval "$(/opt/homebrew/bin/brew shellenv)"
PATH="/Users/qyriad/.local/bin:$PATH"
PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:/opt/homebrew/opt/python/libexec/bin:/usr/local/MacGPG2/bin:$PATH:/opt/homebrew-rosetta/bin"
PATH="/Users/qyriad/.local/share/cargo/bin:$PATH"
export XDG_CACHE_HOME="/Users/qyriad/.cache"
export XDG_CONFIG_HOME="/Users/qyriad/.config"
export XDG_DATA_HOME="/Users/qyriad/.local/share"

export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
