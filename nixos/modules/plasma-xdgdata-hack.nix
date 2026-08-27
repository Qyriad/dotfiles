{ lib, config, ... }:
let
	inherit (lib.options) mkOption;

	t = lib.types;
	cfg = config.hacks.kde-plasma-xdg-datadirs-fix;

	# Copied from <nixpkgs/nixos/modules/misc/nixpkgs.nix>.
	overlayType = lib.mkOptionType {
		name = "nixpkgs-overlay";
		description = "nixpkgs overlay";
		check = lib.isFunction;
		merge = lib.options.mergeOneOption;
	};

	consolidationType = t.submodule ({ config, ... }: {
		options.dirsVarName = mkOption {
			type = t.str;
			description = "Name of the variable to search for entries of in the wrapper args";
			example = "XDG_DATA_DIRS";
		};
		options.dest = mkOption {
			type = t.str;
			description = "Bash expression for the destination to consolidate `dirsVarName` entries into.";
		};

		options.finalRendered = mkOption {
			type = t.str;
			readOnly = true;
			description = "The final 'consolidateFromWrapperIntoDir' call.";
		};

		config.finalRendered = lib.dedent ''
			consolidateFromWrapperIntoDir ${config.dirsVarName} qtWrapperArgs "${config.dest}"
		'';
	});
in
{
	options = {
		hacks.kde-plasma-xdg-datadirs-fix.enable = mkOption {
			type = t.bool;
			default = false;
			example = true;
			description = lib.dedent ''
				Whether to enable a hack to consolidate KDE Plasma's XDG_DATA_DIRS to reduce excessively long environment variables.
			'';
		};

		hacks.kde-plasma-xdg-datadirs-fix.consolidations = mkOption {
			type = t.listOf consolidationType;

			description = "Which dirs to consolidate and where";

			default = [
				{ dirsVarName = "XDG_DATA_DIRS"; dest = "$out/share"; }
				{ dirsVarName = "QT_PLUGIN_PATH"; dest = "$out/lib/qt-6/plugins"; }
			];
		};

		hacks.kde-plasma-xdg-datadirs-fix.finalOverlay = mkOption {
			type = overlayType;
			readOnly = true;
			visible = false;
			description = "The final overlay that's actually applied.";
		};
	};

	config = lib.mkIf cfg.enable {
		# Our only realistic choice is an overlay.
		# The implementation of `services.desktopManager.plasma6.enable`
		# refers to `pkgs.kdePackages.plasma-workspace` directly.
		hacks.kde-plasma-xdg-datadirs-fix.finalOverlay = pkgsFinal: pkgsPrev: {
			kdePackages = pkgsPrev.kdePackages.overrideScope (kdeFinal: kdePrev: {
				plasma-workspace = kdePrev.plasma-workspace.overrideAttrs (finalAttrs: prevAttrs: {
					nativeBuildInputs = prevAttrs.nativeBuildInputs or [ ] ++ [
						pkgsFinal.qpkgs.stdlib.consolidateDirsFromWrapperArgsHook
					];

					preFixup = cfg.consolidations
					|> lib.map ({ dirsVarName, dest, finalRendered }: lib.dedent ''
						mkdir -p "${dest}"
						${finalRendered}
					'')
					|> lib.concatStringsSep "\n";
				});
			});
		};

		nixpkgs.overlays = [ cfg.finalOverlay ];
	};
}
