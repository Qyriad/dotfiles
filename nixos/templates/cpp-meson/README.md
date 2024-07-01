# Qyriad C++ Meson Template

Post `nix flake init` step:

```bash
$ sed -ibak -e "s/PROJECT_NAME/actual-project-name/g" flake.nix package.nix shell.nix meson.build src/meson.build
```
