import os, sys, json, struct

try:
	from psutils import Process
except ImportError:
	pass

try:
	from unidecode import unidecode
except ImportError:
	pass

#
# Xonsh special environment variables.
#

def exit_code():
	try:
		return str(_.rtn)
	except (AttributeError, NameError):
		return '0'

def exit_color():
	try:
		return '{RED}' if _.rtn != 0 else '{GREEN}'
	except (AttributeError, NameError):
		return '{GREEN}'

$PROMPT_FIELDS['exit_code'] = exit_code
$PROMPT_FIELDS['exit_color'] = exit_color
$PROMPT = '{env_name}{GREEN}{user}@{hostname} {#af00ff}{cwd}{#87d7d7}{curr_branch: ({})}{exit_color} {prompt_end}{RESET} '
$TITLE = '{cwd} | {exit_code}'
$CASE_SENSITIVE_COMPLETIONS = True
$DYNAMIC_CWD_ELISION_CHAR = "…"
$DYNAMIC_CWD_WIDTH = "40%"
#$MOUSE_SUPPORT = True
$XONSH_AUTOPAIR = True
$COMMANDS_CACHE_SIZE_WARNING = 8000

$PATH = [f"{$HOME}/.local/bin", f'{$HOME}/.local/share/cargo/bin'] + $PATH

# Use Neovim for everything.
$EDITOR = $(which nvim)
$VISUAL = $EDITOR
$SYSTEMD_EDITOR = $EDITOR
$NETCTL_EDITOR = $EDITOR

# Fix Neovim for stuff like git commit.
no_thread = lambda *a, **kw: False
__xonsh__.commands_cache.predict_threadable = no_thread
#for command in ['nvim', 'git', 'vidir', 'systemctl', 'pacman', 'yay', 'vidir', 'pip', 'pip2', 'pip3']:
	#__xonsh__.commands_cache.threadable_predictors[command] = no_thread

# Make stuff follow XDG.
$XDG_DATA_HOME = f"{$HOME}/.local/share"
$XDG_CACHE_HOME = f"{$HOME}/.cache"
$XDG_CONFIG_HOME = f"{$HOME}/.config"
$XDG_RUNTIME_DIR = "/run/user/" + $(id -u).strip()
$CARGO_HOME = $XDG_DATA_HOME + '/cargo'
$LESSHISTFILE = $XDG_CACHE_HOME + '/less/history'
$LESSKEY = $XDG_CONFIG_HOME + '/less/lesskey'
$TMUX_TMPDIR = $XDG_RUNTIME_DIR
aliases['tmux'] = 'tmux -u'

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
aliases['ex'] = edit($XDG_CONFIG_HOME + '/xonsh/rc.xsh')
aliases['sx'] = 'source ~/.config/xonsh/rc.xsh'
aliases['es'] = edit('~/.config/sway/config')


# Utilities that I want to modify their default arguments, but also colorize if available.
maybe_colorize = { }
maybe_colorize['lspci'] = 'lspci -nn'
maybe_colorize['lsdsk'] = 'lsblk -o NAME,FSTYPE,LABEL,TYPE,MOUNTPOINT,SIZE'
#aliases['lsd'] = 'lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL,PARTLABEL,PARTTYPE'

# Color output. Note: aliases recursive into aliases other than themselves.
if !(which grc):

	# Forced color grc.
	grcc = 'grc --colour=on'
	aliases['grcc'] = grcc

	commands = \
            ['df', 'free', 'ip', 'mount', 'netstat', 'ping', 'as', 'last', 'lsusb', 'netstat', 'lsof']

	for command in commands:
		aliases[command] = 'grc ' + command

		forced = command + 'c' # Force color, even when piping.
		aliases[forced] = f"{grcc} {command}"

	for command, alias in maybe_colorize.items():
		aliases[command] = f'grc {alias}'

		forced = command + 'c' # Force color, even when piping.
		aliases[forced] = f"{grcc} {alias}"

else:
	aliases.update(maybe_colorize)


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
aliases['mime'] = 'xdg-mime'
aliases['ffmpeg'] = 'ffmpeg -hide_banner'
aliases['ffprobe'] = 'ffprobe -hide_banner'
aliases['ffjson'] = 'ffprobe -hide_banner -v quiet -print_format json'
aliases['mpv'] = 'mpv --osd-fractions'
aliases['diskus'] = 'diskus --size-format binary'
aliases['duf'] = 'duf -hide special'
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
aliases['userctl'] = 'systemctl --user'
aliases['ins'] = 'insect'

def _wine32(args):
	overrides = {
		'WINEPREFIX': f"{$HOME}/.wine32",
		'WINEARCH': 'win32',
	}

	with ${...}.swap(**overrides):
		wine @(args)

aliases['wine32'] = _wine32

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


def read_to_bytes(name):
	with open(name, 'rb') as f:
		data = f.read()
	return data


def read_to_string(name):
	with open(name, 'r') as f:
		s = f.read()
	return s


def _ranger_cd(path=None):

	path = path if path else os.getcwd()

	temp = $(mktemp -t tmp.XXXXXX).strip()

	/usr/bin/ranger --choosedir=@(temp) @(path)

	# cd into the new directory, if any.
	if os.path.exists(temp):

		new_path = read_to_string(temp)

		if new_path and new_path != os.getcwd():
			cd @(new_path)

		os.remove(temp)


aliases['ranger'] = _ranger_cd


$RUSTFLAGS = "-C target-cpu=native"


xontrib load output_search
xontrib load whole_word_jumping

