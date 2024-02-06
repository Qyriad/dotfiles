# eval $(brew shellenv) should be called before including this script.

export HOMEBREW_BOOTSNAP=1
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_DISPLAY_INSTALL_TIMES=1
export HOMEBREW_KEEP_OUTPUT=1

PATH="$HOME/.config/bin:$HOME/.local/bin:$PATH"
BREWPREFIX="$HOMEBREW_PREFIX" # Set by eval $(brew shellenv); just making a more convenient name.

export GOPATH="$HOME/.local/opt/go"

COREUTILSBIN="$BREWPREFIX/opt/coreutils/libexec/gnubin"
MAKEBIN="$BREWPREFIX/opt/make/libexec/gnubin"
PYTHONBIN="$BREWPREFIX/opt/python@3.12/libexec/bin:$HOME/Library/Python/3.12/bin"
LLVMBIN="$BREWPREFIX/opt/llvm/bin"
PATH="$COREUTILSBIN:$MAKEBIN:$PYTHONBIN:/usr/local/MacGPG2/bin:$PATH:$LLVMBIN"
export PATH="$HOME/.local/share/cargo/bin:$GOPATH/bin:$PATH"

export XDG_RUNTIME_DIR="$TMPDIR/run"
mkdir -p "$XDG_RUNTIME_DIR"
