# eval $(brew shellenv) should be called before including this script.

export HOMEBREW_DISPLAY_INSTALL_TIMES=1
export HOMEBREW_KEEP_OUTPUT=1

PATH="$HOME/.local/bin:$PATH"
BREWPREFIX="$HOMEBREW_PREFIX" # Set by eval $(brew shellenv); just making a more convenient name.

COREUTILSBIN="$BREWPREFIX/libexec/gnubin"
MAKEBIN="$BREWPREFIX/libexec/gnubin"
PYTHONBIN="$BREWPREFIX/libexec/bin"
LLVMBIN="$BREWPREFIX/bin"
PATH="$COREUTILSBIN:$MAKEBIN:$PYTHONBIN:/usr/local/MacGPG2/bin:$PATH:$LLVMBIN"
export PATH="$HOME/.local/share/cargo/bin:$PATH"
