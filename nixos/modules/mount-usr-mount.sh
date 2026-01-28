#!/usr/bin/env bash

set -euo pipefail

echo "99-mount-usr: mounting /usr to /run/current-system/sw in ${NIXOS_ACTION:-}"

MOUNT="@MOUNT@"

[[ -n "${MOUNT:-}" ]]

declare -a ARGS=()

if [[ "${NIXOS_ACTION:-}" = "dry-activate" ]]; then
	ARGS=("--fake")
fi

if [[ -h /run/current-system ]]; then
	echo -n "99-mount-usr: "
	"$MOUNT" "${ARGS[@]}" --verbose --bind /run/current-system/sw /usr -o ro || echo "oopsie! that didn't work!"
else
	echo "99-mount-usr: /run/current-system is not mounted yet! Nothing to do!"
fi

