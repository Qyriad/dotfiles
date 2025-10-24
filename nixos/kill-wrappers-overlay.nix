# vim: tabstop=4 shiftwidth=0 noexpandtab
final: prev: let
	inherit (final) lib;
in {
	colmena = prev.colmena.overrideAttrs (prev: {
		# We don't need to wrap colmena *just* to put `nix` in its PATH...
		preFixup = lib.dedent ''
			if [[ -f "$out/bin/.colmena-wrapped" ]]; then
				mv -vf "$out/bin/.colmena-wrapped" "$out/bin/colmena"
			fi
		'';
	});

	wl-clipboard = prev.wl-clipboard.overrideAttrs (prev: {
		# Disable nixpkgs' hook, which normally wraps wl-copy to put
		# xdg-mime in its PATH.
		postInstall = null;

		# Instead, we'll make xdg-utils available at build-time...
		buildInputs = prev.buildInputs ++ [ final.xdg-utils ];

		# and patch wl-copy to use an absolute path instead.
		xdgMime = lib.getExe' final.xdg-utils "xdg-mime";

		preConfigure = lib.dedent ''
			substituteInPlace src/util/files.c \
				--replace-fail 'execlp("xdg-mime"' "execlp(\"$xdgMime\""
		'';
	});
}
