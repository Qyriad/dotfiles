{
  buildPythonPackage,
  fetchPypi,
  setuptools,
  wheel,
  astunparse,
  flit-core,
}:
  let
    pname = "fickling";
    version = "0.0.8";
  in
    buildPythonPackage {
      inherit pname version;

      src = fetchPypi {
        inherit pname version;
        hash = "sha256-j7z8DamoYNGSjd4Mhvkq6Llh9dSfr2I/FszgeZ/feCU=";
      };

      format = "pyproject";

      nativeBuildInputs = [
        setuptools
        wheel
      ];

      propagatedBuildInputs = [
        astunparse
        flit-core
      ];

    }


