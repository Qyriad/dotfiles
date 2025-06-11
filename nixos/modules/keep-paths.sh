#!/usr/bin/env bash

mkdir -p "$out/share/nix-support"
# All we need to prevent garbage collection of a store path is to have that
# store path's text exist in the output of a derivation that is included in
# our system derivation.
# Easy enough!
if [[ -n "${echoKeptStorePaths:-}" ]]; then
	local storePathLine
	while IFS= read -r storePathLine; do
		echo "  $storePathLine"
	done < "$closureText"
	cp "$closureText" "$out/share/nix-support/propagated-build-inputs"
fi
