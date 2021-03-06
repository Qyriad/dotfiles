# Lines configured by zsh-newuser-install
HISTFILE=~/.cache/zsh/histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall

zstyle ':completion:*' completer _complete _ignored
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}'
zstyle ':completion:*' menu select=1
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle :compinstall filename '/home/qyriad/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

autoload -Uz promptinit

promptinit

export PROMPT="%F{2}%n@%m %F{129}%~ %F{2}%(! # $) %f"

bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

export PATH="~/.local/bin:/usr/local/bin:~/.local/share/cargo/bin:$DEVKITARM/bin:$PATH"

# Use vim for everything
export EDITOR="/usr/bin/vim"
export VISUAL="/usr/bin/vim"
export SYSTEMD_EDITOR="/usr/bin/vim"
export NETCTL_EDITOR="/usr/bin/vim"

# MAke stuff follow XDG
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export GNUPGHOME="$XDG_CONFIG_HOME"/gnupg
export LESSHISTFILE="$XDG_CACHE_HOME"/less/history
export LESSKEY="$XDG_CONFIG_HOME"/less/lesskey
export TMUX_TMPDIR="$XDG_RUNTIME_DIR"
export VIMINIT=':let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'
alias tmux='tmux -u -f "$XDG_CONFIG_HOME"/tmux/tmux.conf'

alias cmc="rm -rf CMakeCache.txt CMakeFiles Makefile cmake_install.cmake"
alias ec="vim CMakeLists.txt"

# Coreutils and builtins
alias ls='exa'
alias ll="ls -lh"
alias la="ls -Al"
alias cp="cp -vi"
alias rm="rm -vi"
alias mv="mv -vi"
alias ln="ln -vi"
alias chown="chown --preserve-root"
alias chmod="chmod --preserve-root"
alias chgrp="chgrp --preserve-root"
alias grep="grep --color=auto"
alias less="less -R"

# Tar
alias tarx="tar -xvf"
alias tart="tar -tvf"
alias tarc="tar -cvf"

# Edit config shortucts
alias et="vim ~/.config/tmux/tmux.conf"
alias ev="vim ~/.config/vim/vimrc"
alias ei3="vim ~/.config/i3/config"
alias eb="vim ~/.config/bash/bashrc"
alias ex="vim ~/.xinitrc"
alias exr="vim ~/.config/X11/Xresources"
alias ei="vim ~/.config/i3/config"
alias sb="source ~/.bashrc"
alias er="vim ~/.config/ranger/rc.conf"
alias ea='vim ~/.config/alacritty/alacritty.yml'
alias ef='vim ~/.config/fontconfig/fonts.conf'
alias ez='vim ~/.zshrc'
alias sz='source ~/.zshrc'

# Misc
alias wgetc="wget --content-disposition" # Uses server filename across redirects
alias ni="nonet"
alias info="pinfo"
alias sudoe="sudo -E" # I shouldn't always, but sometimes it's really nice to preserve env when editing
alias sudos="sudo -Es"
alias gpc='gpaste-client'
alias sgpc='xargs gpaste-client add'
alias cdconf='cd ~/.config'
alias xdgo='xdg-open'
alias ffprobe="ffprobe -hide_banner"
alias ffmpeg='ffmpeg -hide_banner'
alias prp='realpath .' # "Print real path"
alias tn="tr -d '\n'" # Strip newlines, meant to be used when copying one line of command output to clipboard
alias remake='mkdir $(pwd) ; cd $(pwd)'
alias svim='sudo -E vim'

function source_if()
{
	[ -r "$1" ] && source "$1"
}

zstyle ':completion:*:*:git:*' script /usr/share/git/completion/git-completion.zsh
#source_if /usr/share/git/completion/git-completion.zsh
source_if /usr/share/git/completion/git-prompt.sh
source_if /etc/profile.d/cnf.sh
source_if /etc/profile.d/devkitarm.sh
source_if /etc/profile.d/devkitppc.sh

source_if /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

if [ -z "$TMUX" ]; then # If we're not already in a tmux session
	if [ "$(tty)" != "/dev/tty1" ]; then # and we're not in tty1
		if tmux list-sessions; then # if there's a session, attach
			tmux attach-session -d
		else
			tmux # otherwise, create one
		fi
	fi
fi
