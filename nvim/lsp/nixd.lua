local qyriad = require('qyriad')

return qyriad.nested_tbl {
	cmd = {
		'nixd',
		'--pretty',
		'--inlay-hints',
	},
	filetypes = { 'nix' },
	single_file_support = true,
	['settings.nixd'] = {
		['nixos.expr'] = "(import ~/.).nixos.options",
		--['nixpkgs.expr'] = [[import <nixpkgs> { overlays = [ (builtins.getFlake "qyriad").overlays.default ]}]],
	},
}
