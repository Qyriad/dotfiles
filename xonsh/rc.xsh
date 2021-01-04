#
# Xonsh special environment variables.
#
$PROMPT = '{env_name}{GREEN}{user}@{hostname} {#af00ff}{cwd}{#87d7d7}{curr_branch: ({})}{GREEN} {prompt_end}{RESET} '
$CASE_SENSITIVE_COMPLETIONS = True
$DYNAMIC_CWD_ELISION_CHAR = "…"
$DYNAMIC_CWD_WIDTH = "40%"
#$MOUSE_SUPPORT = True
$XONSH_AUTOPAIR = True

$PATH = [f"~/.local/bin", '~/.local/share/cargo/bin'] + $PATH

# Use Neovim for everything.
$EDITOR = $(which nvim)
$VISUAL = $EDITOR
$SYSTEMD_EDITOR = $EDITOR
$NETCTL_EDITOR = $EDITOR

# Fix Neovim for stuff like git commit.
no_thread = lambda *a, **kw: False
for command in ['nvim', 'git', 'vidir', 'systemctl', 'pacman', 'yay']:
	__xonsh__.commands_cache.threadable_predictors[command] = no_thread

# Make stuff follow XDG.
$XDG_DATA_HOME = f"{$HOME}/.local/share"
$XDG_CACHE_HOME = f"{$HOME}/.cache"
$XDG_CONFIG_HOME = f"{$HOME}/.config"
$XDG_RUNTIME_DIR = "/run/user/" + $(id -u).strip()
$CARGO_HOME = $XDG_DATA_HOME + '/cargo'
$LESSHISTFILE = $XDG_CACHE_HOME + '/less/history'
$LESSKEY = $XDG_CONFIG_HOME + '/less/lesskey'
$TMUX_TMPDIR = $XDG_RUNTIME_DIR
aliases['tmux'] = 'tmux -u -f ' + $XDG_CONFIG_HOME + '/tmux/tmux.conf'

$PAGER = 'less'

# Coreutils.
aliases['ls'] = 'exa --header --group --group-directories-first --classify --binary'
aliases['cp'] = 'cp -vi'
aliases['mv'] = 'mv -vi'
aliases['rm'] = 'rm -vi'
aliases['ln'] = 'ln -vi'
aliases['mkdir'] = 'mkdir -vp'
aliases['chmod'] = 'chmod -v --preserve-root'
aliases['chown'] = 'chown -v --preserve-root'
aliases['chgrp'] = 'chgrp -v --preserve-root'
aliases['grep'] = 'grep --color=auto'
aliases['egrep'] = 'egrep --color=auto'
aliases['less'] = 'less -R'


# Edit config shortcuts.
edit = lambda path : $EDITOR + ' ' + path
aliases['et'] = edit('~/.config/tmux/tmux.conf')
aliases['ev'] = edit('~/.config/nvim/init.vim')
aliases['er'] = edit('~/.config/ranger/rc.conf')
aliases['ea'] = edit('~/.config/alacritty/alacritty.yml')
aliases['ex'] = edit($XDG_CONFIG_HOME + '/rc.xsh')
aliases['sx'] = 'source ~/.config/rc.xsh'

# Color output. Note: aliases are recursive.
if !(which grc):

	# Forced color grc.
	aliases['grcc'] = 'grc --colour=on'

	commands = \
            ['df', 'free', 'ip', 'mount', 'netstat', 'ping', 'as', 'last', 'lsusb', 'netstat', 'lsof']

	for command in commands:
		aliases[command] = 'grc ' + command

		forced = command + 'c' # Force color, even when piping.
		aliases[forced] = 'grcc ' + command

	aliases['lspci'] = 'grc lspci -nn'
	aliases['lspcic'] = 'grcc lspci -nn'

else:

	aliases['lspci'] = 'lspci -nn'

# Forced normal terminal output for things besides grc, even when piping.
aliases['grepc'] = 'grep --color=always'
aliases['egrepc'] = 'egrep --color=always'
aliases['jqc'] = 'jq --color-output'
aliases['watchc'] = 'watch --color'
aliases['rgc'] = 'rg --smart-case --color=always --heading --line-number' # --smart-case is in the normal alias.
aliases['fdc'] = 'fd --color=always'

# rg and fd no ignore
# use -g and --glob for globbing (! negates).
aliases['rg'] = 'rg --smart-case'
aliases['rgi'] = 'rg --smart-case --no-ignore'
aliases['rgih'] = 'rg --no-ignore --hidden'
# use -E, --exclude for globbing
aliases['fdi'] = 'fd --no-ignore'

# Miscellaneous.
aliases['wgetc'] = 'wget --content-disposition' # Uses server filename across redirects.
aliases['gpc'] = 'gpaste-client'
aliases['xdgo'] = 'xdg-open'
aliases['ffmpeg'] = 'ffmpeg -hide_banner'
aliases['ffprobe'] = 'ffprobe -hide_banner'
aliases['ffjson'] = 'ffprobe -hide_banner -v quiet -print_format json'
aliases['mpv'] = 'mpv --osd-fractions'
aliases['diskus'] = 'diskus --size-format binary'
aliases['prp'] = 'realpath .' # "Print real path".
aliases['tn'] = r"tr -d '\n'"
aliases['remake'] = 'mkdir $PWD ; cd $PWD'
aliases['rsync'] = 'systemd-inhibit --mode=block --what=shutdown:sleep:idle --who=qyriad --why=rsync --no-pager --no-legend rsync --recursive -hhh --links -v --info=PROGRESS2'
aliases['rsyncn'] = '/usr/bin/rsync --recursive -hhh --links -v --info=PROGRESS2'
aliases['lsync'] = 'systemd-inhibit --mode=block --what=shutdown:sleep:idle --who=qyriad --why=rsync --no-pager --no-legend rsync --whole-file --recursive -hhh --links -v --info=PROGRESS2'
aliases['lsyncn'] = '/usr/bin/rsync -rvhhh --links --checksum --whole-file --info=progress2'
aliases['rclone'] = 'rclone -P'
aliases['pgrep'] = 'pgrep --list-full --ignore-case'
aliases['ppid'] = 'ps -o ppid= -p' # Get parent pid of process specified by pid.
aliases['lsdsk'] = 'lsblk -o NAME,FSTYPE,LABEL,TYPE,MOUNTPOINT,SIZE'
aliases['lsd'] = 'lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL,PARTLABEL,PARTTYPE'
#aliases['wine32'] = '$WINEPREFIX=~/.wine32 WINEARCH=win32 wine'
aliases['userctl'] = 'systemctl --user'
aliases['ins'] = 'insect'

def _cmplinux():
	boot = $(uname -r)
	installed = $(basename /usr/lib/modules/*arch*)
	if boot != installed:
		#delta <@(boot) <@(installed) | tail -2
		sh -c f"delta <(echo {boot}) <(echo {installed}) | tail -2"
	else:
		echo @(boot)
		echo @(installed)

aliases['cmplinux'] = _cmplinux

def _mkcd(path):
	mkdir -vp @(path)
	cd @(path)

aliases['mkcd'] = _mkcd

def _appfd(pattern):
	fd @(pattern) /usr/share/applications ~/.local/share/applications

aliases['appfd'] = _appfd

def _apprg(pattern):
	rg @(pattern) /usr/share/applications ~/.local/share/applications

aliases['apprg'] = _apprg

def _copyfrom(hostname):
	ssh @(hostname) tmux show-buffer | wl-copy

aliases['copyfrom'] = _copyfrom

def _reenv():
	source-bash --aliascmd '' $(tmux show-environment -s | rg -v unset)

aliases['reenv'] = _reenv

def _rekey():
	$GPG_TTY = $(tty).strip()
	$SSH_AUTH_SOCK = $(gpgconf --list-dirs agent-ssh-socket).strip()
	gpg-connect-agent updatestartuptty reloadagent /bye > /dev/null

aliases['rekey'] = _rekey

def _ftail(path):
	tail -f @(path) 2>&1 | perl -ne "if (/file truncated/) {system 'clear'} else {print}"

aliases['ftail'] = _ftail

def _delssh(linenum):
	sed -i @(linenum)d ~/.ssh/known_hosts

aliases['delssh'] = _delssh

$RUSTFLAGS = "-C target-cpu=native"


xontrib load output_search
xontrib load whole_word_jumping


import os, sys
