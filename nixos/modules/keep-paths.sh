#!/usr/bin/env bash

# shellcheck enable=all
# shellcheck disable=SC2250

set -euo pipefail

# "$out" is set by derivation attr.
# shellcheck disable=SC2154
mkdir -p "$out/share/nix-support"

# All we need to prevent garbage collection of a store path is to have that
# store path's text exist in the output of a derivation that is included in
# our system derivation.
# Easy enough!

function echoKeptForClosureIdx()
{
	if [[ -z "${echoKeptStorePaths:-}" ]]; then
		return
	fi

	local idx
	idx="$1"
	local name
	local closurePath

	name="${storePathNames["$idx"]}"
	# "var is referenced but not assigned"
	# shellcheck disable=SC2154 # storePathValues is set by derivation attr.
	closurePath="${storePathValues["$idx"]}"

	local -a closureLines
	closureLines=()

	# Yes this is how you read lines into an array from a file in Bash.
	while IFS= read -r storePathLine; do
		closureLines+=("$storePathLine")
	done < "$closurePath"

	local numPathsInClosure
	numPathsInClosure="${#closureLines[@]}"
	if [[ "$numPathsInClosure" = "1" ]]; then
		# If there was only one closure path, chill.
		echo "  ${closureLines[0]} for '$name'"
	else
		# If there were multiple for this name, format it nicely.
		echo "  for '$name':"
		for pathInClosure in "${closureLines[@]}"; do
			echo "    $pathInClosure"
		done
	fi
}

function keepPaths()
{
	if [[ -n "${storePathNames[*]:-}" ]]; then
		if [[ -n "${echoKeptStorePaths:-}" ]]; then
			echo "preventing the following paths from being garbage collected:"
		fi

		for idx in "${!storePathNames[@]}"; do
			echoKeptForClosureIdx "$idx"

			local closurePath
			closurePath="${storePathValues["$idx"]}"

			cat "$closurePath" >> "$out/share/nix-support/propagated-build-inputs"
		done
	fi
}

keepPaths
