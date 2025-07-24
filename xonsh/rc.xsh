# XXX VERY HACK for NixOS
import xonsh
if "IN_NIX_SHELL" not in ${...}:
	if xonsh.__path__[0].startswith('/nix/store'):
		to_delete = []
		for elem in $PATH:
			if pf'{elem}/xonsh'.is_file() and not elem.startswith('/run'):
				to_delete.append(elem)
		for elem in to_delete:
			$PATH.remove(elem)

import builtins, operator, typing
import os, sys, io, errno, ctypes
import struct, re, shlex, textwrap, functools
from datetime import datetime, timedelta
import zoneinfo
from zoneinfo import ZoneInfo
import pathlib
from pathlib import Path

import xonsh
from xonsh.events import events

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

try:
	import pipe
	from pipe import Pipe, select, where, skip, take
except ImportError:
	pass

try:
	import requests

	#
	# You want to see cursed? I'll give you cursed~
	#
	def response_repr(self):
		s = [f"<Response [{self.status_code}]>"]
		if json_data := self.json():
			s.append(str(json_data))
		elif self.content:
			s.append(self.content.decode(errors="backslashreplace"))

		return "\n".join(s)

	requests.Response.__repr__ = response_repr

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

def shlvl_diff():
	# The SHLVL above baseline.
	# Without tmux, the baseline is 1. In tmux, the baseline is 2.
	if "TMUX" in ${...}:
		return str(int($SHLVL) - 2)
	return str(int($SHLVL) - 1)

if "TMUX" in ${...}:
	def _prompt_escape():
		return "\x01\x1b]133;A\x1b\\\x02"
else:
	def _prompt_escape():
		return ""


$PROMPT_FIELDS['exit_code'] = exit_code
$PROMPT_FIELDS['exit_color'] = exit_color
$PROMPT_FIELDS['shlvl'] = shlvl_diff
$PROMPT_FIELDS['prompt_escape'] = _prompt_escape
$TITLE = '{cwd} | {exit_code} | SL {shlvl}'
$PROMPT = '{env_name}{GREEN}{user}@{hostname} {PURPLE}{cwd}{INTENSE_CYAN}{curr_branch: ({})}{exit_color} {prompt_end}{RESET} {prompt_escape}'
$CASE_SENSITIVE_COMPLETIONS = False
$DYNAMIC_CWD_ELISION_CHAR = "…"
$DYNAMIC_CWD_WIDTH = "40%"
#$MOUSE_SUPPORT = True
$XONSH_AUTOPAIR = False
$AUTO_PUSHD = True
$COMMANDS_CACHE_SIZE_WARNING = 8000
$CMD_COMPLETIONS_SHOW_DESC = True # Show path to binary in description of command completions.
$XONSH_HISTORY_SIZE = "10 GB"

aliases['ni-ignore'] = ['rg', '-v', r'(-usr)|(-env)|(-fhs)|(-extracted)']
aliases['nej'] = ['nix-eval-jobs', '--log-format', 'bar-with-logs', '--option', 'allow-import-from-derivation', 'false', '--verbose']

aliases['sudo'] = lambda args : $[@($(which -s sudo)) @(aliases.eval_alias(args))]

# Use Neovim for everything.
$EDITOR = $(which nvim)
$VISUAL = $EDITOR
$SYSTEMD_EDITOR = $EDITOR
$NETCTL_EDITOR = $EDITOR

# Open nvim in read-only mode, pretending that the specified file is not actually a file
aliases['nvimscratch'] = 'nvim -R "+setlocal buftype=nofile bufhidden=hide noswapfile"'
aliases['rnvim'] = 'nvim -R'

# Fix Neovim for stuff like git commit.
#no_thread = lambda *a, **kw: False
#__xonsh__.commands_cache.predict_threadable = no_thread
#for command in ['nvim', 'git', 'vidir', 'systemctl', 'pacman', 'yay', 'vidir', 'pip', 'pip2', 'pip3']:
	#__xonsh__.commands_cache.threadable_predictors[command] = no_thread

# Make stuff follow XDG.
if sys.platform != 'darwin':
	#$XDG_RUNTIME_DIR = "/run/user/" + $(id -u).strip()
	$XDG_RUNTIME_DIR = f"/run/user/{os.getuid()}"

if "XDG_RUNTIME_DIR" in ${...}:
	$TMUX_TMPDIR = $XDG_RUNTIME_DIR

$CARGO_HOME = $XDG_DATA_HOME + '/cargo'
$LESSHISTFILE = $XDG_CACHE_HOME + '/less/history'
$LESSKEY = $XDG_CONFIG_HOME + '/less/lesskey'
aliases['tmux'] = 'tmux -u'

$PAGER = $(which moar).strip()
$DELTA_PAGER = 'less'

def Pipe__repr__(self):
	return str(self())

if 'Pipe' in globals():
	Pipe.__repr__ = Pipe__repr__

aliases['tolist'] = 'Pipe(list)'

# Coreutils.
aliases['ls'] = 'eza -l --header --group --group-directories-first --classify --binary'
# You know. For mODified.
aliases['lsod'] = 'eza -l --header --group --group-directories-first --classify --binary --sort=modified'
aliases['lsg'] = 'eza -l --header --group --group-directories-first --classify --binary --git --git-ignore'
aliases['cp'] = 'cp -vi'
aliases['mv'] = 'mv -vi'
aliases['rm'] = 'rm -vI'
aliases['ln'] = 'ln -vi'
aliases['mkdir'] = 'mkdir -vp'
aliases['chmod'] = 'chmod -v --preserve-root'
aliases['chown'] = 'chown -v --preserve-root'
aliases['chgrp'] = 'chgrp -v --preserve-root'
aliases['grep'] = 'grep --color=auto'
aliases['egrep'] = 'egrep --color=auto'
aliases['sed'] = 'sed -E'
aliases['less'] = 'less -R'
aliases['tp'] = 'trash-put -v'
aliases['lsof'] = 'grc lsof +c0'
#aliases['man'] = ['env', 'MANWIDTH=@(min(int($(tput cols)), 120))',  'man']

# Coreutils-alike
aliases['rip'] = 'rip --seance'

def _rmlink(args: list):
	""" Like `unlink(1)`, but allows multiple arguments. """
	echo @(args) | xargs -n1 echo-exec unlink
aliases['rmlink'] = _rmlink

# Edit config shortcuts.
#edit = lambda path : $EDITOR + ' ' + str(path)
def edit(path):
	return [$EDITOR, Path(path).as_posix()]
# "Edit tmux"
aliases['et'] = [$EDITOR, p"~/.config/tmux/tmux.conf".as_posix()]
# "Edit vim"
aliases['ev'] = f"$EDITOR -S ~/.config/Session-nvim.vim"
# "Edit alacritty"
aliases['ea'] = edit(p'~/.config/alacritty/alacritty.yml')
# "Edit xonsh"
aliases['ex'] = edit($XDG_CONFIG_HOME + '/xonsh/rc.xsh')
# "Edit wezterm"
aliases['ew'] = [$EDITOR, "-O", p"~/.config/wezterm/wezterm.lua", p"~/.config/wezterm/utils.lua"]
# "Source xonsh"
aliases['sx'] = 'source ~/.config/xonsh/rc.xsh'
# "Edit Nix"
aliases['en'] = f"$EDITOR -S ~/.config/Session-nix.vim"

aliases['yt-dlp'] = 'yt-dlp --compat-options filename,format-spec,multistreams'

aliases['lg'] = 'lazygit'

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
aliases['xh'] = 'xh --all --verbose --check-status'
aliases['xhs'] = 'xhs --all --verbose --check-status'
aliases['xdgo'] = 'xdg-open'
aliases['mime'] = 'xdg-mime'
aliases['ffmpeg'] = 'ffmpeg -hide_banner'
aliases['ffprobe'] = 'ffprobe -hide_banner'
aliases['ffjson'] = 'ffprobe -hide_banner -v quiet -print_format json -show_format -show_streams'
aliases['exifjson'] = 'exiftool -json -g -struct -b'
aliases['mpv'] = 'mpv --osd-fractions'
aliases['diskus'] = 'diskus --size-format binary'
aliases['duf'] = 'duf -hide special'
aliases['prp'] = 'realpath .' # "Print real path".
aliases['tn'] = r"tr -d '\n'"
# XXX
#aliases['remake'] = 'mkdir $PWD ; cd $PWD'
aliases['rsync'] = 'rsync --recursive -hhh --links -v --info=progress2'
aliases['lsync'] = 'systemd-inhibit --mode=block --what=shutdown:sleep:idle --who=qyriad --why=rsync --no-pager --no-legend rsync --whole-file --recursive -hhh --links -v --info=PROGRESS2'
aliases['lsyncn'] = '/usr/bin/rsync -rvhhh --links --checksum --whole-file --info=progress2'
aliases['rclone'] = 'rclone -P'
aliases['pgrep'] = 'pgrep -i'
aliases['ppid'] = 'ps -o ppid= -p' # Get parent pid of process specified by pid.
aliases['userctl'] = 'systemctl --user'
aliases["busctl"] = ["busctl", "--full", "--verbose"]
aliases['ins'] = 'insect'
aliases['silicon'] = 'silicon --no-window-controls --pad-horiz=20 --pad-vert=20'
aliases["moaro"] = [$PAGER, "-quit-if-one-screen"]
aliases['jg'] = 'jj'
aliases['jgn'] = 'jj --ignore-working-copy --no-pager'
aliases['hyfetch'] = 'env SHELL=xonsh hyfetch'
aliases['dedent'] = lambda args, stdin: textwrap.dedent(stdin.read())
aliases['striptext'] = lambda args, stdin: stdin.read().strip()
aliases['tcopy'] = 'tmux load-buffer -w -'
aliases['tpaste'] = 'tmux save-buffer -'
aliases['nopager'] = 'env PAGER=cat GIT_PAGER=cat'
# strace --color=always --silence=attach,exit --signal=none -y -e read,write -s999
# strace handy arguments:
# -z / --successful-only
# -Z --failed-only
# --silence=attach,exit
# --signal=none
# -y / --decode-fds
# -Y / --decode-pids=comm (print command names for pids)
# -X verbose / --const-print-style=verbose (output named constants as numbers with name as a comment)
# -s 64 --string-limit=64
# --tips / --tips=id:random,format:compact
aliases['stracey'] = ['strace', '-yyY', '-s', '128', '--silence=attach,exit', '--signal=none', '--tips=id:random,format:compact']
aliases['strace-exec'] = ['strace', '--silent=attach,exit', '-s', '9999', '--signal=!all', '--successful-only' '--follow-forks' '--seccomp-bpf', '-e' 'execve']

# objdump handy arguments:
# -M intel
# --demangle
aliases['objdumpx'] = ['objdump', '--special-syms', '--disassembler-color=extended', '--visualize-jumps=extended-color']


$YTDLP_YOUTUBE = '%(channel)s/%(upload_date>%Y-%m-%d,release_date>%Y-%m-%d)s - %(title)s [%(id)s].%(ext)s'
$YTDLP_TWITCH  = '%(uploader)s/%(upload_date>%Y-%m-%d,release_date>%Y-%m-%d)s - %(title)s [%(id)s].%(ext)s'

$FFMPEG_MUX_ONLY = shlex.split("-map_metadata 0 -map_chapters 0 -map 0 -c:v copy -c:a copy -c:s copy")

xontrib load abbrevs
if 'abbrevs' not in globals():
	aliases['mesoncomp'] = 'meson compile -C build'
	aliases['mesoncompile'] = 'meson compile -C build'
	aliases['mesontest'] = 'meson test -C build'
	aliases['mesoninstall'] = 'meson install -C build'
else:
	abbrevs['mesoncomp'] = 'meson compile -C build'
	abbrevs['mesoncompile'] = 'meson compile -C build'
	abbrevs['mesontest'] = 'meson test -C build'
	abbrevs['mesoninstall'] = 'meson install -C build'
	abbrevs['gitcb'] = lambda buffer, word: XSH.shell.shell.prompt_formatter('<edit>{curr_branch}')

def _wine32(args):
	overrides = {
		'WINEPREFIX': f"$HOME/.wine32",
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
	gpg-connect-agent reloadagent /bye > /dev/null

aliases['reagent'] = _reagent

def _rekey():
	$SSH_AUTH_SOCK = $(gpgconf --list-dirs agent-ssh-socket).strip()
	gpg-connect-agent reloadagent /bye > /dev/null
	#$GPG_TTY = $(tty).strip()
#gpg-connect-agent updatestartuptty reloadagent /bye > /dev/null

aliases['rekey'] = _rekey

def _ftail(path):
	tail -f @(path) 2>&1 | perl -ne "if (/file truncated/) {system 'clear'} else {print}"

aliases['ftail'] = _ftail

def _delssh(linenum):
	sed -i @(linenum)d ~/.ssh/known_hosts

aliases['delssh'] = _delssh

def runlist(cmds: list[list]):
	with ${...}.swap(RAISE_SUBPROC_ERROR=True):
		for cmd in cmds:
			print(' '.join([shlex.quote(arg) for arg in cmd]))
			@(cmd)

def _proc_get(p, key):
	if key == "pid":
		return p.pid
	return getattr(p, key)()

def _procs(**kwargs):
	import psutil
	res = []
	for p in psutil.process_iter():
		for key, value in kwargs.items():
			if _proc_get(p, key) == value:
				res.append(p)

	return res

def _psearch(args: list):
	args = dict([arg.split("=") for arg in args])
	processes = _procs(**args)
	return "\n".join([str(p.pid) for p in processes])

aliases["psearch"] = _psearch

def _xonsh_dev_env(installable):
	from tempfile import NamedTemporaryFile
	with NamedTemporaryFile('w') as nixenv:
		# Capture the environment setup commands from Nix.
		envdata = $(nix print-dev-env @(installable))

		# Handle error when executing the Nix command.
		if not envdata:
			return

		# Can't trust Nix to do this...
		nixenv.write('set -e\n')

		# Write environment setup file. Must be a file or else Xonsh fails when executing imported bash functions.
		nixenv.write(envdata)

		# Flush to make sure it's ready by the time we source it
		nixenv.flush()

		# Using an RC file allows Xonsh to continue running with the sourced environment
		with NamedTemporaryFile('w') as xonshrc:

			xonshrc.write(f'source-bash {nixenv.name}\n')

			xonshrc.flush()

			# Start Xonsh using our environment then the Nix one, this prevents a few issues.
			# Yes the argument syntax for multiple RC files is cursed like this, lol.
			![xonsh --rc ~/.config/xonsh/rc.xsh @(xonshrc.name)]

aliases['nix-devenv'] = _xonsh_dev_env
aliases['nix-internal-to-json'] = [
	'sed',
	's/^@nix //',
]
aliases['nix-json-to-raw'] = [
	"jq",
	r'. | map(.fields[0]) | map(select(type == "string")) | join("\n")',
	'--raw-output',
	'--slurp',
]


aliases['hlas'] = 'bat --paging never --tabs=4 --style=plain -l'

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

if 'gac_alias' in XSH.completers:
	completer remove gac_alias

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

envs_pattern = re.compile(r"\$(.+?)\b")
def envs(s: str):
	return [envs_pattern.sub(lambda varmatch: os.environ.get(varmatch.group(1), ""), s)]

def _bak(args: list):
	for file in args:
		# Be a bit smart. If we were given something like `bak foo.txt.bak`,
		# and `foo.txt` exists but `foo.txt.bak` doesn't, then operate on `foo.txt` instead.
		# This is particularly helpful for things like pressing <Up> and changing an `unback`
		# command to a `bak` command without having to change the filename argument.
		if file.endswith(".bak"):
			double_bak = Path(f"{file}.bak")
			if not double_bak.exists():
				file = str(file).removesuffix(".bak")

		$[mv @(file) f"{file}.bak"]

def _unbak(args: list):
	for file in args:
		# Be a bit smart. If we were given something like `unbak foo.txt`,
		# and `foo.txt` doesn't exist but `foo.txt.bak` does, then operate on `foo.txt.bak` instead.
		# This is particularly helpful for things like pressing <Up> and changing a `bak`
		# command to be an `unbak` command without having to change the filename argument.
		if not file.endswith(".bak"):
			with_bak = f"{file}.bak"
			if not Path(file).exists() and Path(with_bak).exists():
				file = with_bak

		$[mv @(file) f"{file.removesuffix('.bak')}"]

aliases["bak"] = _bak
aliases["unbak"] = _unbak

def _nix_create_dev_files(args: list):
	import platform
	nix_system = f"{platform.machine()}-{platform.system()}".lower()
	$[mkdir -p .nix]
	dev_envs = json.loads($(nix flake show --json | jq f'.devShells["{nix_system}"] | keys'))
	for dev_env in dev_envs:
		$[nix print-dev-env f".#{dev_env}" > f".nix/{dev_env}.sh"]

aliases["nix-create-dev-files"] = _nix_create_dev_files

def _git_root(path=None):
	path = Path(path) if path is not None else Path($PWD)
	if pf"{path}/.git".is_dir():
		return path
	for parent in path.parents:
		if pf"{parent}/.git".is_dir():
			return parent

@xonsh.tools.unthreadable
def _git_workout(args: list):
	# Get the git root.
	git_root = _git_root($PWD)
	# Get available branches.
	branches = $(git branch --list '--format=%(refname:lstrip=2)').strip().split('\n')
	branch = args[0]
	echo f"git-workout: using branch {branch}"
	if branch in ["main", "master"]:
		$[cd @(git_root)]
		return
	$[mkdir -p f"{git_root}/.w/{branch}"]
	# Check if the worktree already exists
	if not pf"{git_root}/.w/{branch}/.git".is_file():
		if branch not in branches:
			echo f':: git worktree add -b "{git_root}/.w/{branch}" f"{branch}"'
			$[git worktree add f"{git_root}/.w/{branch}" -b f"{branch}"]
		else:
			echo f':: git worktree add "{git_root}/.w/{branch}" f"{branch}"'
			$[git worktree add f"{git_root}/.w/{branch}" f"{branch}"]

	$[cd f"{git_root}/.w/{branch}"]

aliases["git-workout"] = _git_workout

@xonsh.tools.unthreadable
def _git_diff_merge(args: list):
	main = args[0]
	feature = args[1]
	merge_base = $(git merge-base @(feature) @(main)).strip()
	$[git diff f"{merge_base}..{feature}"]

aliases["git-diff-merge"] = _git_diff_merge

def _per_line(args: list, stdin: io.TextIOWrapper):
	"""
		Callable alias that you can pass a lambda to to process stdin line-by-line. e.g.:
		@ cat ./foo.txt | pl @(lambda line: line.split()[2])
		to get the second whitespace-delimited word of each line.
	"""
	callback: typing.Callable[[str], str] = args[0]
	output = "\n".join([str(callback(line)) for line in stdin])
	print(output)
	return output

aliases["pl"] = _per_line

def _intext(args: list, stdin: io.TextIOWrapper):
	callback: typing.Callable[[str], str] = args[0]
	output = callback(stdin.read())
	print(output)
	return output

# Like per-line, but for the entire stdin text at once.
aliases["intext"] = _intext

# Append a trailing newline, since some commands don't.
aliases["withnl"] = lambda args, stdin: _intext([print], stdin)

# The first parentheses are a non-capturing group that matches whitespace or the start of the string.
# The second parenthese are the group we're interested in.
# The third is a lookahead assertion (to not consume) for whitespace or the end of the string.
UNQUOTED_INSTALLABLE_PATTERN = re.compile(r"(?:\s|^)+(\w+#\w+)(?=\s|$)+")
@events.on_transform_command
def unfuck_nix_installabes(cmd: str):
	if installables := UNQUOTED_INSTALLABLE_PATTERN.findall(cmd):
		for installable in installables:
			cmd = cmd.replace(installable, f'"""{installable}"""')

	return cmd


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

class ShortcutAutovar:
	def __init__(self, callback):
		self.callback = callback
		self.value = None

	def __repr__(self):
		self.value = self.callback()
		return str(self.value)

	def __getattr__(self, key):
		return getattr(self.value, key)

# Git dir
#from xonsh.prompt import gitstatus
#$gitd = ShortcutAutovar(lambda : Path($PROMPT_FIELDS['gitstatus.branch'].value).resolve())
#$gitb = ShortcutAutovar(xonsh.prompt.vc.current_branch)

#$LIB = EnvPath([
#	'/home/qyriad/.local/opt/xwin/crt/lib/x64/',
#	'/home/qyriad/.local/opt/xwin/sdk/Lib/ucrt/x64',
#	'/home/qyriad/.local/opt/xwin/sdk/lib/um/x64/'
#])


# xontrib-abbrevs, xonsh-direnv, xontrib-term-integrations, xontrib-broot
xontrib load -s abbrevs, direnv, term_integration, broot

if "abbrevs" in globals():
	abbrevs["|&"] = "2>&1 |"

abbrevs['procinfo'] = 'ps -wwch -o user,pid,ppid,ucomm,state,%mem=MEM%,%cpu=CPU%,args -p'

#xontrib load output_search
#xontrib load whole_word_jumping
#xontrib load argcomplete

