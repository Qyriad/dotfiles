{
  lib,
  xonsh-source,
  stdlib,
  python3Packages,
  python-pipe,
  xontrib-abbrevs,
  xonsh-direnv,
  # FIXME: requires a patch to sitecustomize.py
  gobject-introspection,
  gtk3,
  gtk4,
  glib,
  graphene,

  # Setting `programs.xonsh.package` to this causes NixOS to call
  # `.override { extraPackages = }` on us.
  extraPackages ? lib.const [ ],
  __checks ? extraPackages python3Packages == [ ],
}: lib.callWith' python3Packages ({
  unidecode,
  psutil,
  requests,
  jsondiff,
  setproctitle,
  httpx,
  tqdm,
  pip,
  pydbus,
  jeepney,
  pygobject3,
  ds-store,
  xmltodict,
  python-box,
  matplotlib,
  pillow,
  pytesseract,
  beautifulsoup4,
  python-fontconfig,
  keyring,
}: stdlib.mkSimpleEnv (self: assert __checks; {
  extraAttrs.xonsh = python3Packages.xonsh.overridePythonAttrs {
    src = xonsh-source;
  };

  layers = [
    self.xonsh
    python-pipe
    xontrib-abbrevs
    xonsh-direnv

    unidecode
    psutil
    requests
    jsondiff
    setproctitle
    httpx
    tqdm
    pip
    pydbus
    jeepney
    pygobject3
    ds-store
    xmltodict
    python-box
    matplotlib
    pillow
    pytesseract
    beautifulsoup4
    python-fontconfig
    keyring
    pygobject3
    gtk4
    #glib
    #graphene
    #gobject-introspection
  ] ++ lib.concatLists [
    self.xonsh.propagatedBuildInputs
  ];

  extraAttrs.pythonShebang = "#!" + (builtins.placeholder "out") + "/bin/python3";

  # FIXME: patch all Python things in /bin
  postInstall = ''
    sed --in-place -e "1c$pythonShebang" "$out/bin/xonsh"
    sed --in-place -e "1c$pythonShebang" "$out/bin/xonsh-cat"
    sed --in-place -e "1c$pythonShebang" "$out/bin/xonsh-uname"
    sed --in-place -e "1c$pythonShebang" "$out/bin/xonsh-uptime"
  '';

  extraAttrs.meta.mainProgram = "xonsh";
}))
