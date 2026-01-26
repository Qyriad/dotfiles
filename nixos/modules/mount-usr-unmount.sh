#!/usr/bin/env bash

set -euo pipefail

echo "01-unmount-usr: unmounting /usr"

MOUNTPOINT="@MOUNTPOINT@"
UMOUNT="@UMOUNT@"

[[ -n "${MOUNTPOINT:-}" ]]
[[ -n "${UMOUNT:-}" ]]

declare -a ARGS=()

if [[ "${NIXOS_ACTION:-}" = "dry-activate" ]]; then
	ARGS=("--fake")
fi

if "$MOUNTPOINT" /usr >/dev/null; then
	echo -n "01-unmount-usr: "
	"$UMOUNT" "${ARGS[@]}" --verbose /usr
else
	echo "01-unmount-usr: /usr is not a mountpoint; nothing to do"
fi
