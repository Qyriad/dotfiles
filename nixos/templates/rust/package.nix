{
	lib,
	craneLib,
}: let

	commonArgs = {
		src = craneLib.cleanCargoSource ./.;
		strictDeps = true;
	};

	cargoArtifacts = craneLib.buildDepsOnly commonArgs;

in craneLib.buildPackage (commonArgs // {

	inherit cargoArtifacts;

	passthru.mkDevShell = {
		self,
		rust-analyzer,
	}: craneLib.devShell {
		inputsFrom = [ self ];
		packages = [ rust-analyzer ];
	};

	meta = {
		mainProgram = null;
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
	};
})
