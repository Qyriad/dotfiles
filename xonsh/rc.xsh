#$SHELL = "xonsh"

import os, sys, json, struct, re, shlex
from datetime import datetime, timedelta
import zoneinfo
from zoneinfo import ZoneInfo

# These variables are set to lambdas, and are not exported to subprocesses
# unless they have been evaluated at least once, it seems.
$HOSTNAME
$HOSTTYPE

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
$CASE_SENSITIVE_COMPLETIONS = False
$DYNAMIC_CWD_ELISION_CHAR = "…"
$DYNAMIC_CWD_WIDTH = "40%"
#$MOUSE_SUPPORT = True
$XONSH_AUTOPAIR = False
$COMMANDS_CACHE_SIZE_WARNING = 8000
$CMD_COMPLETIONS_SHOW_DESC = True # Show path to binary in description of command completions.

aliases['sudo'] = lambda args : $[@($(which -s sudo)) @(aliases.eval_alias(args))]

# Use Neovim for everything.
$EDITOR = $(which nvim)
$VISUAL = $EDITOR
$SYSTEMD_EDITOR = $EDITOR
$NETCTL_EDITOR = $EDITOR

# Fix Neovim for stuff like git commit.
#no_thread = lambda *a, **kw: False
#__xonsh__.commands_cache.predict_threadable = no_thread
#for command in ['nvim', 'git', 'vidir', 'systemctl', 'pacman', 'yay', 'vidir', 'pip', 'pip2', 'pip3']:
	#__xonsh__.commands_cache.threadable_predictors[command] = no_thread

# Make stuff follow XDG.
if sys.platform != 'darwin':
	#$XDG_RUNTIME_DIR = "/run/user/" + $(id -u).strip()
	$XDG_RUNTIME_DIR = f"/run/user/{os.getuid()}"
	$TMUX_TMPDIR = $XDG_RUNTIME_DIR

$CARGO_HOME = $XDG_DATA_HOME + '/cargo'
$LESSHISTFILE = $XDG_CACHE_HOME + '/less/history'
$LESSKEY = $XDG_CONFIG_HOME + '/less/lesskey'
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
aliases['sed'] = 'sed -E'
aliases['less'] = 'less -R'

# Coreutils-alike
aliases['rip'] = 'rip --seance'


# Edit config shortcuts.
edit = lambda path : $EDITOR + ' ' + str(path)
# "Edit tmux"
aliases['et'] = edit(p'~/.config/tmux/tmux.conf')
# "Edit vim"
aliases['ev'] = f"{$EDITOR} -S ~/.config/Session-nvim.vim"
# "Edit alacritty"
aliases['ea'] = edit(p'~/.config/alacritty/alacritty.yml')
# "Edit xonsh"
aliases['ex'] = edit($XDG_CONFIG_HOME + '/xonsh/rc.xsh')
# "Edit wezterm"
aliases['ew'] = f"{$EDITOR} -O ~/.config/wezterm/wezterm.lua ~/.config/wezterm/utils.lua"
# "Source xonsh"
aliases['sx'] = 'source ~/.config/xonsh/rc.xsh'
# "Edit Nix"
aliases['en'] = f"{$EDITOR} -S ~/.config/Session-nix.vim"

aliases['yt-dlp'] = 'yt-dlp --compat-options filename,format-spec,multistreams'


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
		['df', 'free', 'ip', 'mount', 'netstat', 'ping', 'as', 'last', 'lsusb', 'netstat', 'lsof', 'ifconfig']

	for command in commands:
		aliases[command] = 'grc ' + command

		forced = command + 'c' # Force color, even when piping.
		aliases[forced] = f"{grcc} {command}"

	for command, alias in maybe_colorize.items():
		aliases[command] = f'grc {alias}'

		forced = command + 'c' # Force color, even when piping.
		aliases[forced] = f"{grcc} {alias}"

	del commands, command, forced

else:
	aliases.update(maybe_colorize)

del maybe_colorize

if sys.platform == 'darwin':
	#aliases['df'] = 'grc --colour=on df -Ph | rg -v "/System/Volumes.+?/(VM|Preboot|Update)"'
	aliases['df'] = 'grc df -Ph'
	aliases['brewfd'] = 'fd --no-ignore-vcs -L'


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
aliases['rsync'] = 'rsync --recursive -hhh --links -v --info=progress2'
aliases['lsync'] = 'systemd-inhibit --mode=block --what=shutdown:sleep:idle --who=qyriad --why=rsync --no-pager --no-legend rsync --whole-file --recursive -hhh --links -v --info=PROGRESS2'
aliases['lsyncn'] = '/usr/bin/rsync -rvhhh --links --checksum --whole-file --info=progress2'
aliases['rclone'] = 'rclone -P'
aliases['pgrep'] = 'pgrep -l -i'
aliases['ppid'] = 'ps -o ppid= -p' # Get parent pid of process specified by pid.
aliases['userctl'] = 'systemctl --user'
aliases["busctl"] = ["busctl", "--full", "--verbose"]
aliases['ins'] = 'insect'


aliases['cm'] = 'cmake -B build'
aliases['cmb'] = 'cmake --build build'

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
	if boot.find('lts') >= 0:
		installed = $(basename /usr/lib/modules/*lts*)
	else:
		installed = $(basename /usr/lib/modules/*arch*)

	with open("/tmp/boot", "w") as f:
		f.write(boot)

	with open("/tmp/installed", "w") as f:
		f.write(installed)

	if boot != installed:
		#delta <@(boot) <@(installed) | tail -2
		#sh -c f"delta <(echo {boot}) <(echo {installed}) | tail -2"
		delta /tmp/boot /tmp/installed | tail -2
	else:
		echo @(boot.strip())
		echo @(installed.strip())

	/bin/rm -f /tmp/boot /tmp/installed

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

def _tmuxman(what):
	man tmux | less rf"+/^\s+{what[0]}"

aliases['tmuxman'] = _tmuxman

def _copyfrom(hostname):
	ssh @(hostname) tmux show-buffer | wl-copy

aliases['copyfrom'] = _copyfrom

def _rm_transient(name):
	systemctl --user show @(name) -p FragmentPath | cut -d= -f2 | xargs rm -i

aliases['rm-transient'] = _rm_transient

def _reenv():
	source-bash --aliascmd '' $(tmux show-environment -s | rg -v unset)

aliases['reenv'] = _reenv

def _reagent():
	$SSH_AUTH_SOCK = $(gpgconf --list-dirs agent-ssh-socket).strip()

aliases['reagent'] = _reagent

def _rekey():
	$SSH_AUTH_SOCK = $(gpgconf --list-dirs agent-ssh-socket).strip()
	#$GPG_TTY = $(tty).strip()
#gpg-connect-agent updatestartuptty reloadagent /bye > /dev/null

aliases['rekey'] = _rekey

def _ftail(path):
	tail -f @(path) 2>&1 | perl -ne "if (/file truncated/) {system 'clear'} else {print}"

aliases['ftail'] = _ftail

def _delssh(linenum):
	sed -i @(linenum)d ~/.ssh/known_hosts

aliases['delssh'] = _delssh

def _gac(name):
	git cherry-pick -n @(name)
	git reset

aliases['gac'] = _gac


def _gitls(args):
	git ls-tree HEAD --name-only | xargs @$(which ls) -d @(args)

aliases['gitls'] = _gitls

#def _s(subst):
	#cmd = $(history show -1 | sed -E @(subst)).strip()
	#print(cmd)
	#@(cmd.split())


#aliases['s'] = _s


def _gac(name):
	git cherry-pick -n @(name)
	git reset

aliases['gac'] = _gac

bashcomp = __xonsh__.completers['bash']

#def _gac_complete(prefix, line, start, end, ctx):
	#if line.startswith("gac "):
		#return bashcomp(prefix, line.replace("gac", "git cherry-pick", 1), start, end, ctx)
	#else:
		#return None

#__xonsh__.completers["gac"] = _gac_complete
#__xonsh__.completers.move_to_end("gac", last=False)

import xonsh
from xonsh.completers.tools import *
from xonsh.parsers.completion_context import CommandArg
@contextual_completer
def _gac_completer(context):

	if context.command and context.command.args and context.command.args[0].value == 'gac':

		if len(context.command.args) > 1:
			old_args = context.command.args[1:]
		else:
			old_args = ()

		new_args = (
			CommandArg(value='git'),
			CommandArg(value='cherry-pick'),
		) + old_args

		new_arg_index = context.command.arg_index + 1
		new_command = context.command._replace(args=new_args, arg_index=new_arg_index)
		new_context = context._replace(command=new_command, python=None)

		return bashcomp(new_context)

completer add gac_alias _gac_completer


def read_to_bytes(name):
	with open(name, 'rb') as f:
		data = f.read()
	return data


def read_to_string(name):
	with open(name, 'r') as f:
		s = f.read()
	return s


def addr(val):
	return '0x{:09_x}'.format(val)


def _ranger_cd(path=None):

	path = path if path else os.getcwd()

	temp = $(mktemp -t tmp.XXXXXX).strip()

	@($(which -s ranger).strip()) --choosedir=@(temp) @(path)

	# cd into the new directory, if any.
	if os.path.exists(temp):

		new_path = read_to_string(temp)

		if new_path and new_path != os.getcwd():
			cd @(new_path)

		os.remove(temp)


aliases['ranger'] = _ranger_cd


def _detach_kernel_drivers(dev):
	for i in range(len(dev.configurations()[0].interfaces())):
		try:
			dev.detach_kernel_driver(i)
		except usb.core.USBError:
			pass

aliases['detach-kernel-drivers'] = _detach_kernel_drivers

class NixWith:
	def __init__(self):
		import argparse
		self.parser = argparse.ArgumentParser("nix-with")
		self.parser.add_argument("packages", type=str)
		self.defaults = "--log-format bar-with-logs --verbose --command xonsh".split()

		del argparse

	def __call__(self, args: list[str]):
		args, rest = self.parser.parse_known_args(args)
		packages = [f"nixpkgs#{pkg}" for pkg in args.packages.split()]
		command = ["nix", "shell", *packages, *rest, *self.defaults]
		print(shlex.join(command))
		return ![@(command)]

aliases["nix-with"] = NixWith()

envs_pattern = re.compile(r"\$(.+?)\b")
def envs(s: str):
	return [envs_pattern.sub(lambda varmatch: os.environ.get(varmatch.group(1), ""), s)]


#
# Horrible datetime convenience functions and types.
#

def localnow():
	""" Because datetime.now() returns a timezone-less datetime for some reason. """
	return datetime.now().astimezone()

def localtz():
	return localnow().tzinfo

def utcnow():
	return datetime.now().astimezone(ZoneInfo('UTC'))

class Nicely:
	"""
	This is a terrible yet amazing hack we've come up with to make printing
	certain kinds of values in convenient formatting easier to read.

	Ex: >>> datetime.now() + timedelta(days=90) >> nicely
	'Sunday, December 12 2022 (12/04/22 5:08:29 PM)'

	Truly, we have become C++.
	"""

	def _datetime(self, dt: datetime) -> str:
		return dt.strftime("%A, %B %d %Y (%m/%d/%Y %-I:%M:%S %p) %Z (UTC%z)")

	def __rrshift__(self, other) -> str:
		if isinstance(other, datetime):
			return self._datetime(other)
		else:
			raise TypeError()

nicely = Nicely()

class ToZone:
	""" An even worse hack. """

	def __init__(self, zone):
		if isinstance(zone, ZoneInfo):
			self.zone = zone
		elif isinstance(zone, str):
			try:
				self.zone = ZoneInfo(zone)
			except zoneinfo._common.ZoneInfoNotFoundError:
				for name in zoneinfo.available_timezones():
					if name.split('/')[-1].lower() == zone.lower():
						self.zone = ZoneInfo(name)
						break
				else:
					raise
		else:
			raise TypeError()

	def __getattr__(self, attr):
		return getattr(self.zone, attr)

	def __rrshift__(self, other):
		if isinstance(other, datetime):
			return other.astimezone(tz=self.zone)
		else:
			raise TypeError()

zone = ToZone


xontrib load abbrevs
xontrib load direnv

#abbrevs["|&"] = "2>&1 |"

xontrib load output_search
xontrib load whole_word_jumping
xontrib load term_integration
#xontrib load argcomplete

