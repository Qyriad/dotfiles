{
  buildPythonPackage,
  fetchPypi,
  setuptools,
  wheel,
}:
  let
    pname = "cint";
    version = "1.0.0";
  in
    buildPythonPackage {
      inherit pname version;

      src = fetchPypi {
        inherit pname version;
        hash = "sha256-ZvAm0oxG756pY1vlyzQlBsahr4DRHLHIgaiJjKQp/JE=";
      };

      format = "pyproject";

      nativeBuildInputs = [
        setuptools
        wheel
      ];

    }
