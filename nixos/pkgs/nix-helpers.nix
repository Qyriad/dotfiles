{ pkgs, lib }:

let
  inherit (pkgs) writeShellScriptBin stdenv;
  inherit (builtins) getAttr toString;

  rebuild-cmd = pkgs.writeShellScriptBin "rebuild"
    ''
      cmd="sudo nixos-rebuild --print-build-logs --verbose $@"
      echo $cmd
      exec $cmd
    '';

  nixpkgs-cmd = pkgs.writeShellScriptBin "nixpkgs"
    ''
      echo $(nix eval --impure --expr "<nixpkgs>")
    '';
in
  stdenv.mkDerivation rec {
    pname = "nix-helpers";
    version = "0.1.0";

    src = ./.;

    buildInputs = [
      rebuild-cmd
      nixpkgs-cmd
    ];

    buildInputOuts = lib.forEach buildInputs (dep: "${dep.out}");
    depOuts = lib.forEach buildInputs (dep: lib.forEach dep.outputs (output: toString (getAttr output dep)));

    buildPhase = ''
      for dep in $depOuts; do
        for fileOut in $dep/**/*; do
          normalized="$dep"
          if [[ -d "$normalized" ]]; then
            normalized="$dep/"
          fi
          lenToStrip=''${#normalized}
          fileRelToDepBase=''${fileOut:$lenToStrip}
          mkdir -p "$(basename $out/fileRelToDepBase)"
          echo ln -s "$fileOut" "$out/$fileRelToDepBase"
          ln -s "$fileOut" "$out/$fileRelToDepBase"
        done
      done
    '';

    dontTest = true;
  }
