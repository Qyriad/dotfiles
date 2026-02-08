#!/usr/bin/env python3
import argparse
from datetime import datetime
import copy
from pathlib import Path
from fcntl import fcntl, F_SETFL, F_GETFL
import functools
import json
import io
import os
import selectors
import shlex
import shutil
import subprocess
import sys
import typing
from typing import Any
from zoneinfo import ZoneInfo
import time

# ffmpeg -progress 'pipe:1' -nostdin -f video4linux2 -framerate 60 -video_size 1920x1080 -input_format yuyv422 -fflags nobuffer -i /dev/v4l/by-id/usb-Elgato_Game_Capture_HD60_S+_0004C809C2000-video-index0 -vf format=yuyv422 -f video4linux2 /dev/video10

@functools.cache
def resolve_cmd(command: str) -> str:
    if found := shutil.which(os.environ.get(command.upper().replace('-', '_'), command)):
        return found

    raise FileNotFoundError(f"no {command} found in PATH, nor overriden with ${command.upper()}")

_LOG_PATH: Path | None = None
_LOG_FILE: io.TextIOBase | None = None
def log_file() -> io.TextIOBase:
    global _LOG_PATH
    global _LOG_FILE
    if _LOG_FILE:
        return _LOG_FILE

    if not _LOG_PATH:
        if from_systemd := os.environ.get('LOGS_DIRECTORY', None):
            log_dir = Path(from_systemd)
        elif xdg := os.environ.get('XDG_STATE_HOME'):
            log_dir = Path(xdg) / 'log'
        else:
            log_dir = Path('/var/log')

        try:
            log_dir.mkdir(parents=True, exist_ok=True)
        except OSError as e:
            print(f"couldn't mkdir log directory: {e}")
        _LOG_PATH = log_dir / "ffcap.log"

    _LOG_FILE = open(_LOG_PATH, "a")

    return _LOG_FILE

_seen_exceptions = set()
def write_log(*args, **kwargs):
    global _seen_exceptions
    try:
        kwargs['file'] = log_file()
        kwargs['flush'] = True
        print(*args, **kwargs)
    except Exception as e:
        msg = str(e)
        if msg not in _seen_exceptions:
            _seen_exceptions.add(msg)
            print(f"(Ignored): Error writing to log file: {e}", file=sys.stderr, flush=True)


NOTIFY_ENABLED = "NOTIFY_SOCKET" in os.environ
HAS_NOTIFIED = False

DEBUG_PREFIX = '<7>: ' if NOTIFY_ENABLED else ''

class FpsBuffer(list[float]):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._every10 = 0

    def _push(self, fps: float):
        self.insert(0, fps)
        if len(fps_buffer) > 10:
            self._every10 += 1
            self.pop()

        if self._every10 >= 100:
            write_log(f"FPS AVG: {self._avg()}")
            self._every10 = 0

    def _avg(self) -> float | None:
        if len(self) < 10:
            return None

        return sum(self) / float(len(self))

fps_buffer: FpsBuffer = FpsBuffer()

def _add_fps(fps: float):
    fps_buffer._push(fps)

def _avg_too_low(threshold: float = 45.0) -> bool:
    avg = fps_buffer._avg()
    return avg is not None and avg < threshold

    #if len(fps_buffer) < 10:
    #    return False
    #
    #avg = sum(fps_buffer) / float(len(fps_buffer))
    #return avg < threshold

def _stop_if_fps_too_low(stdout: bytes, threshold: float = 30.0):
    lines = stdout.decode('utf-8', errors='backslashreplace').splitlines()
    try:
        line = next(filter(lambda line: line.startswith('fps='), lines))
    except StopIteration:
        line = 'fps=0.0'

    try:
        (_, fps) = line.split('=')
    except ValueError:
        return

    try:
        fps = float(fps)
    except ValueError:
        return

    if fps < threshold * 1.1:
        print(f"<5>: FPS is low: {fps=}", flush=True)
        write_log(f"FPS is low: {fps=}")

    _add_fps(fps)
    #print(f"{fps_buffer=}", flush=True)
    if _avg_too_low(threshold):
        raise TimeoutError(f"data rate got too low ({fps=})")

def proxy_to_stdout(file: io.FileIO):
    global HAS_NOTIFIED
    data = file.read()

    if NOTIFY_ENABLED and not HAS_NOTIFIED and b'progress=continue' in data:
        print("startup!", flush=True)
        subprocess.check_call(["systemd-notify", "--ready"], executable=resolve_cmd("systemd-notify"))
        HAS_NOTIFIED = True

    _stop_if_fps_too_low(data)

    if not data:
        raise TimeoutError("no stdout received in 4 seconds")

def proxy_to_stderr(file: io.FileIO):
    data = file.read()
    for line in data.decode('utf-8').splitlines():
        pass
        #print(f'{DEBUG_PREFIX}{line}')


def mainloop(in_systemd: bool, selector: selectors.BaseSelector):
    pass

def make_nonblocking(file: typing.IO[Any]):
    orig_flags = fcntl(file, F_GETFL)
    fcntl(file, F_SETFL, orig_flags | os.O_NONBLOCK)

def autodetect_capturecard() -> Path:
    args = [
        *shlex.split(f"udevadm info --export-db --subsystem-match=video4linux"),
        "--property-match=ID_V4L_CAPABILITIES=:capture:",
        "--json=short", # Load-bearing, if there are multiple matches.
        "--no-pager",
    ]
    output = subprocess.check_output(
        args=args,
        executable=resolve_cmd("udevadm"),
        universal_newlines=True,
        encoding='utf-8',
    )

    if not output:
        raise FileNotFoundError()

    results: list[dict[str, str]] = []

    for line in output.splitlines():
        results.append(json.loads(line))

    if len(results) > 1:
        print("<2> multiple autodetect results found; using first one", flush=True)

    found = results[0]
    devlinks = shlex.split(found.get("DEVLINKS", ""))
    preferred = next(link for link in devlinks if "by-id" in link)

    print(f"<3> preferred found: {preferred}", flush=True)

    devnode = Path(preferred)
    if not devnode.exists():
        raise FileNotFoundError(devnode)

    return devnode

def autodetect_output() -> Path:
    args = [
        *shlex.split("udevadm info --export-db --subsystem-match=video4linux"),
        "--property-match=ID_V4L_CAPABILITIES=:video_output:",
        "--json=short", # Load-bearing, if there are multiple matches.
        "--no-pager",
    ]
    output = subprocess.check_output(
        args=args,
        executable=resolve_cmd("udevadm"),
        universal_newlines=True,
        encoding='utf-8',
    )

    if not output:
        raise FileNotFoundError()

    results: list[dict[str, str]] = []
    for line in output.splitlines():
        results.append(json.loads(line))

    found = results[0]
    devname = Path(found['DEVNAME'])
    if not devname.exists():
        raise FileNotFoundError(devname)
    return devname



def make_tristate_optional_type(t: typing.Callable) -> typing.Callable:
    def inner(value: bool | Any):
        match value:
            case bool(b):
                return b
            case other:
                return t(other)

    return inner


class TristateOptionalAction(argparse.Action):
    """ `type` specifies what it should be besides True or False. """
    def __init__(self,
         option_strings,
         dest,
         type,
         *,
         required=False,
         default=None,
         help=None,
         metavar=None,
         deprecated=False
    ):
        opt_strs = []
        for opt_str in option_strings:
            opt_strs.append(opt_str)
            if opt_str.startswith("--"):
                opt_strs.append("--no-" + opt_str[2:])

        super().__init__(
            option_strings=opt_strs,
            dest=dest,
            type=make_tristate_optional_type(type),
            default=default,
            nargs='?',
            help=help,
            metavar=metavar,
            deprecated=deprecated,
        )

        #print(f"{self=}")

    def _get_kwargs(self):
        return [
            ('option_strings', [self.option_strings[0]]),
            ('dest', self.dest),
            ('nargs', self.nargs),
            ('default', self.default),
            ('help', self.help),
            ('required', self.required),
        ]

    def __call__(self, parser: argparse.ArgumentParser, namespace: argparse.Namespace, values, option_string=None):
        print(f"{values=}\n{option_string=}", flush=True)
        if option_string not in self.option_strings:
            return
        assert option_string is not None

        is_no = option_string.startswith("--no")
        if is_no and values is not None:
            raise argparse.ArgumentError(self, f"{option_string} does not take a value")

        if values is not None:
            setattr(namespace, self.dest, values)
        setattr(namespace, self.dest, not option_string.startswith("--no"))

    def format_usage(self):
        opt_str = self.option_strings[0]
        return f"[--no-]{opt_str}[=pattern]"


class HelpFormatter(argparse.HelpFormatter):
    def __init__(self, prog, indent_increment=2, max_help_position=48, width=None):
        super().__init__(
            prog,
            indent_increment=indent_increment,
            max_help_position=max_help_position,
            width=width
        )

    @typing.override
    def _format_action_invocation(self, action: argparse.Action):
        if not isinstance(action, TristateOptionalAction):
            return super()._format_action_invocation(action)

        name = action.option_strings[0]
        return f'--[no-]{name}[=PAT]'



def main():
    parser = argparse.ArgumentParser("ffcap",
        #formatter_class=HelpFormatter,
        #usage="%(prog)s [-h] [--timeout TIMEOUT] [[--no]-autodetect[=PAT]] ...",
    )
    parser.add_argument("--timeout", type=float, default=4)
    parser.add_argument("--framerate", type=int, default=60)
    parser.add_argument("--video-size", type=str, default="1920x1080")
    parser.add_argument("--input-format", type=str, default="yuyv422")
    parser.add_argument("--output-format", type=str, default="yuyv422",)
    #parser.add_argument("--autodetect", action=argparse.BooleanOptionalAction)
    #parser.add_argument("--autodetect", action=TristateOptionalAction, type=str, metavar="PAT",
    #    help="try to find",
    #)
    #parser.add_argument("args", nargs=argparse.REMAINDER)

    args = parser.parse_args()
    timeout: float = args.timeout
    devnode = autodetect_capturecard().as_posix()
    outnode = autodetect_output().as_posix()

    time.sleep(1)

    ffargs = [
        "ffmpeg",
        "-progress", "pipe:1",
        "-nostdin",
        *"-f video4linux2".split(),
        "-framerate", f"{args.framerate}",
        "-video_size", args.video_size,
        "-input_format", args.input_format,
        *"-fflags nobuffer".split(),
        "-i", devnode,
        #"-vf", "format=yuyv422",
        "-vf", f"format={args.output_format}",
        "-f", "video4linux2",
        outnode,
    ]

    print(ffargs, flush=True)

    proc = subprocess.Popen(ffargs, stdout=subprocess.PIPE, stderr=subprocess.PIPE, bufsize=0, executable=resolve_cmd("ffmpeg"))
    print(f"{proc=}", flush=True)
    assert proc.stdout is not None
    assert proc.stderr is not None

    make_nonblocking(proc.stdout)
    make_nonblocking(proc.stderr)

    selector = selectors.DefaultSelector()
    selector.register(proc.stdout, selectors.EVENT_READ, data=proxy_to_stdout)
    selector.register(proc.stderr, selectors.EVENT_READ, data=proxy_to_stderr)

    has_notified = False

    while True:
        try:
            events = selector.select(timeout)
            if not events:
                raise TimeoutError(f"no events within {timeout} seconds")
            for key, mask in events:
                key.data(key.fileobj)

        except KeyboardInterrupt:
            print("Killed by CtrlC", flush=True)
            proc.kill()
            raise

        except subprocess.TimeoutExpired as e:
            print(f"Timed out: {e}", flush=True)
            proc.kill()
            raise
        except Exception as e:
            print(f"Other error {e}", flush=True)
            proc.kill()
            raise

if __name__ == "__main__":
    main()
