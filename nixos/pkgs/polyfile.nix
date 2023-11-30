# should be called with pythonPackages.callPackage
{
  buildPythonApplication,
  fetchFromGitHub,
  setuptools,
  setuptools-scm,
  pip,
  git,
  wheel,
  abnf,
  chardet,
  cint,
  fickling,
  graphviz,
  intervaltree,
  jinja2,
  kaitaistruct,
  networkx,
  pdfminer-six,
  pillow,
  pyyaml,
  cxxfilt,
  kaitai-struct-compiler,
}:
  let
    pname = "polyfile";
    version = "0.5.4";
  in
    buildPythonApplication {
      inherit pname version;
      src = fetchFromGitHub {
        owner = "trailofbits";
        repo = "polyfile";
        name = "${pname}-source";
        rev = "v${version}";
        hash = "sha256-I+PBvu12D76YJnGhk0jBZwDcEEkM0k+WXfWswYnKvnQ=";
        fetchSubmodules = true;
        deepClone = true;
      };

      nativeBuildInputs = [
        setuptools
        setuptools-scm
        wheel
        pip
        git
        kaitai-struct-compiler
      ];

      # FIXME: figure out why this fails
      dontUseSetuptoolsCheck = true;

      propagatedBuildInputs = [
        abnf
        chardet
        cint
        fickling
        graphviz
        intervaltree
        jinja2
        kaitaistruct
        networkx
        pdfminer-six
        pillow
        pyyaml
        cxxfilt
      ];
    }
