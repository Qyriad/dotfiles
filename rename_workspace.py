#!/bin/env python3

import sys
import json
import subprocess

def main():
    workspace_array = json.loads(
        subprocess
        .run(['swaymsg', '-t', 'get_workspaces', '--raw'], stdout=subprocess.PIPE)
        .stdout.decode('utf8'))

    # find current workspace
    for workspace in workspace_array:
        if workspace['focused']:
            current_workspace = workspace

    # "sanitize" the workspace name
    name: str = current_workspace['name']
    colon_index = name.find(': ')
    if colon_index is not None:
        name_without_number = name[(colon_index + 2):] # +2 to account for the space after
        number = name[:colon_index]
    else:
        # not a named workspace, then
        name_without_number = name
        number = name

    # run bemenu to prompt for the new name
    bemenu_process_stdin: str = '{}\0'.format(name_without_number).encode('utf8')
    new_name = subprocess \
        .run(['bemenu', '-p "rename workspace: "'], input=bemenu_process_stdin, stdout=subprocess.PIPE) \
        .stdout

    # trim the newline
    new_name: str = (new_name.decode('utf8'))[:-1]
    subprocess.run(['swaymsg', 'rename', 'workspace', 'to', '{}: {}'.format(number, new_name)])

if __name__ == '__main__':
    main()
