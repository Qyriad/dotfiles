export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_RUNTIME_DIR="/run/user/1000"
export TMUX_TMPDIR="$XDG_RUNTIME_DIR"
alias tmux="tmux -u -f $XDG_CONFIG_HOME/tmux/tmux.conf"
