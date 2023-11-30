{
  buildPythonPackage,
  fetchPypi,
  setuptools,
  setuptools-scm,
  wheel,
}:
  let
    pname = "abnf";
    version = "2.2.0";
  in
    buildPythonPackage {
      inherit pname version;

      src = fetchPypi {
        inherit pname version;
        hash = "sha256-QzOA/TKFW7xgvHs9NdQGFuITg6Mu0cm4iT0W2fSmwvQ=";
      };

      format = "pyproject";

      nativeBuildInputs = [
        setuptools
        setuptools-scm
        wheel
      ];

    }
