{
  fetchFromGitHub,
  buildPythonApplication,
  setuptools,
  wheel,
  pytest,
}:

let
  pname = "strace-process-tree";
  version = "1.4.0";
in
  buildPythonApplication {
    inherit pname version;
    src = fetchFromGitHub {
      name = "${pname}-source";
      owner = "mgedmin";
      repo = pname;
      rev = version;
      sha256 = "sha256-kM2ciZmTy0HQOcgiwkBD/gs+aZx9r9lA1TsT3siNLCg=";
    };

    nativeBuildInputs = [
      setuptools
      wheel
    ];

    nativeCheckInputs = [
      pytest
    ];
}
