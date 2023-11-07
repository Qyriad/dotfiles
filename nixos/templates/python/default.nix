{ python3Packages }:

let
  inherit (builtins) attrValues readFile fromTOML;
  version = fromTOML (readFile ./pyproject.toml);
in
  python3Packages.buildPythonApplication {
    name = "foo";
    inherit version;
    src = ./.;
    format = "pyproject";

    checkImports = [
      "foo"
    ];

    nativeBuildInputs = attrValues {
      inherit (python3Packages)
        setuptools
        wheel
      ;
    };
  };
