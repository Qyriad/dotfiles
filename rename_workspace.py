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

    # "sanitize" the workspace name: format: <n>:<n>: s
    name: str = current_workspace['name']
    colon_index = name.find(':')
    name_index = name.find(':', colon_index + 1) + 1 # +1 to account for the :
    if colon_index is not None:
        name_without_number = name[name_index:]
        number = name[:colon_index]
        print('name without: {}'.format(name_without_number))
        print('number: {}'.format(number))
    else:
        # not a named workspace, then
        name_without_number = name
        number = name

    # run bemenu to prompt for the new name
    bemenu_process_stdin: str = '{}\0'.format(name_without_number).encode('utf8')
    new_name = subprocess \
        .run(['bemenu', '-p "rename workspace: "'], input=bemenu_process_stdin, stdout=subprocess.PIPE) \
        .stdout

    if new_name != b'':
        # trim the newline
        new_name: str = (new_name.decode('utf8'))[:-1]
        subprocess.run(['swaymsg', 'rename', 'workspace', 'to', '{}:{}: {}'.format(number, number, new_name)])
    else:
        pass # cancel

if __name__ == '__main__':
    main()
