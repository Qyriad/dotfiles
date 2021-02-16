#!/usr/bin/env python3

import sys
import argparse
import subprocess

from subprocess import PIPE

import dbus


def main():

    parser = argparse.ArgumentParser()
    parser.add_argument("-n", "--count", type=int, dest='count')

    args = parser.parse_args()

    bus = dbus.SessionBus()
    gpaste = bus.get_object('org.gnome.GPaste', '/org/gnome/GPaste')
    interface = dbus.Interface(gpaste, dbus_interface="org.gnome.GPaste2")

    count = args.count

    items = {}
    # s = ''

    for i in range(count):
        # items.append(interface.GetElementAtIndex(i))
        item = interface.GetElementAtIndex(i)
        # print(str(item[1]), end='\0')
        # items.append(item[1].encode('utf-8'))
        items[item[1].encode('utf-8')] = item[0]

    # print(type(items[0]), items[2])
    fzf_in = b'\0'.join(items.keys())
    # print(s)

    fzf_stdout = subprocess.run(['fzf', '--read0'], stdout=PIPE, input=fzf_in, check=True).stdout

    if not fzf_stdout.startswith(b'[Image'):
        wl_copy = subprocess.Popen(['wl-copy', '-n'], stdin=PIPE)
        wl_copy.stdin.write(fzf_stdout)
        wl_copy.stdin.close()
        wl_copy.wait()
        # interface.Select(items[fzf_stdout.strip()])
    else:
        uuid = items[fzf_stdout.strip()]
        # print(list({k: v} for k, v in items.items() if b'Image,' in k))
        path = interface.GetRawElement(uuid)
        # subprocess.call(['eog', path], subprocess.)
        # subprocess.Popen(['eog', path], close_fds=True)
        subprocess.call(['swaymsg', 'exec', f'eog {path}'])
        # subprocess.call(['swaymsg', 'floating', 'enable'])


    # fzf = subprocess.Popen(['fzf', '--read0'], stdout=PIPE, stdin=PIPE)
    # outs, errs = fzf.communicate(input=s)
    # print(fzf.stdout)

if __name__ == '__main__':
    main()
