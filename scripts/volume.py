#!/usr/bin/env python3

import os
import sys
# import argparse
import subprocess

import psutil


def main():

    # parser = argparse.ArgumentParser()
    # parser.add_argument("adjustment", type=str, action='store')
    # args = parser.parse_args()
    adjustment = sys.argv[1]
    subprocess.check_call(['pactl', 'set-sink-volume', '@DEFAULT_SINK@', adjustment])

    swaysock = os.environ['SWAYSOCK']
    wob_path = f'{swaysock}.wob'

    if not os.path.exists(wob_path):
        subprocess.check_call(['swaymsg', 'exec', f'mkfifo {wob_path} && tail -f {wob_path} | wob'])

    try:
        next(filter(lambda process : process.name() == 'wob', psutil.process_iter(['name'])))
    except StopIteration:
        subprocess.check_call(['swaymsg', 'exec', f'tail -f {wob_path} | wob'])

    current_vol = subprocess.check_output(['pamixer', '--get-volume'])
    with open(wob_path, 'wb') as wob:
        wob.write(current_vol)


if __name__ == '__main__':
    main()
