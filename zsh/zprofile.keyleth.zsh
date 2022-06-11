eval "$(/opt/homebrew/bin/brew shellenv)"
export HOMEBREW_DISPLAY_INSTALL_TIMES=1
export HOMEBREW_KEEP_OUTPUT=1
PATH="/Users/qyriad/.local/bin:$PATH"
COREUTILSBIN="/opt/homebrew/opt/coreutils/libexec/gnubin"
MAKEBIN="/opt/homebrew/opt/make/libexec/gnubin"
PYTHONBIN="/opt/homebrew/opt/python@3.10/libexec/bin"
PATH="$COREUTILSBIN:$MAKEBIN:$PYTHONBIN:/usr/local/MacGPG2/bin:$PATH:/opt/homebrew-rosetta/bin:/opt/homebrew/opt/llvm/bin"
PATH="/Users/qyriad/.local/share/cargo/bin:$PATH"
export XDG_CACHE_HOME="/Users/qyriad/.cache"
export XDG_CONFIG_HOME="/Users/qyriad/.config"
export XDG_DATA_HOME="/Users/qyriad/.local/share"

export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
