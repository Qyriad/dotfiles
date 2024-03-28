#!/usr/bin/env bash
set -euo pipefail

function run()
{
	echo "$@"
	$@
}

sysAppDir="$1"

echo "setting up /Applications/Nix"

if [[ -e "/Applications/Nix" ]]; then
	echo "removing existing /Applications/Nix"
	rm -rf "/Applications/Nix"
fi

find "$sysAppDir/Applications" -maxdepth 1 -type l | while read linkName; do
	linkTarget="$(readlink $linkName)"
	appName="$(basename "$linkTarget")"
	appTargetDir="/Applications/Nix"
	appTarget="$appTargetDir/$appName"

	if [[ -e "$appTarget" ]]; then
		echo "removing existing $appTarget"
		rm -rvf "$appTarget"
		#run find "$appTarget" -type l -exec "unlink" "{}" ";"
		#run find "$appTarget" "(" -not -path "$appTarget" ")" -and "(" -type d ")" -depth -exec "rmdir" "{}" ";"
		#type cp
	fi

	echo "creating $appTarget from $linkTarget"
	mkdir -p "$appTargetDir"
	run cp -r "$linkTarget" "$appTargetDir"
done
