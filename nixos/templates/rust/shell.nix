{
	pkgs ? import <nixpkgs> { },
	qpkgs ? let
		src = fetchTarball "https://github.com/Qyriad/nur-packages/archive/main.tar.gz";
	in import src { inherit pkgs; },
	fenixLib ? let
		src = fetchTarball "https://github.com/nix-community/fenix/archive/main.tar.gz";
	in import src { inherit pkgs; },
	fenixBaseToolchain ? fenixLib.stable.withComponents [
		"rustc"
		"llvm-tools"
		"rust-std"
		"rust-docs"
		"rust-src"
		"rustc-dev"
		"clippy"
	],
	fenixToolchain ? fenixLib.combine [
		fenixBaseToolchain
		fenixLib.latest.cargo
		# Rustfmt is very handy to have as nightly.
		fenixLib.latest.rustfmt
	],
	# For the dev shell, use lld for faster linking.
	clangStdenv ? pkgs.clangStdenv.override {
		cc = pkgs.clangStdenv.cc.override {
			bintools = pkgs.wrapBintoolsWith { inherit (pkgs.llvmPackages) bintools; };
		};
	},
	PKGNAME ? import ./default.nix { inherit pkgs qpkgs clangStdenv; },
}: let
	inherit (pkgs) lib;

	mkDevShell = PKGNAME: qpkgs.callPackage PKGNAME.mkDevShell { inherit fenixToolchain; };
	devShell = mkDevShell PKGNAME;

	byStdenv = lib.mapAttrs (lib.const mkDevShell) PKGNAME.byStdenv;

in devShell.overrideAttrs (prev: lib.recursiveUpdate prev {
	passthru = { inherit byStdenv; };
})
