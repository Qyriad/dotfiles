#!/bin/env python3

import sys
import json
import subprocess

def main():
    get_workspaces_process = subprocess \
        .run(['swaymsg', '-t', 'get_workspaces', '--raw'], stdout=subprocess.PIPE)

    output_array = json.loads(get_workspaces_process.stdout.decode('utf8'))

    desired_workspace = sys.argv[1]

    wanted_workspace = None

    for workspace in output_array:
        name: str = workspace['name']
        if name.startswith(desired_workspace):
            print('found workspace {}'.format(name))
            wanted_workspace = workspace
            break

    if wanted_workspace is None:
        subprocess.run(['swaymsg', 'workspace', '{}'.format(desired_workspace)])
    else:
        subprocess.run(['swaymsg', 'workspace', wanted_workspace['name']])

if __name__ == '__main__':
    main()
