#!/usr/bin/env bash

set -euo pipefail

echo "99-mount-usr: mounting /usr to /run/current-system/sw"

MOUNT="@MOUNT@"

[[ -n "${MOUNT:-}" ]]

declare -a ARGS=()

if [[ "${NIXOS_ACTION:-}" = "dry-activate" ]]; then
	ARGS=("--fake")
fi

echo -n "99-mount-usr: "
"$MOUNT" "${ARGS[@]}" --verbose --bind /run/current-system/sw /usr
