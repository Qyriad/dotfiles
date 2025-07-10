/** Provide fetched flake inputs for any inputs that *aren't* provided via the
 * `explicitInputs` attrset argument.
 *
 * This is for making our Nix files agnostic across flake-vs-non-flake.
 */
let
  # We must make do without `lib` here.
  # Builtins and hand-rolled only.
  inherit (builtins)
    parseFlakeRef
    fetchTree
    mapAttrs
    removeAttrs
    attrNames
    concatStringsSep
  ;

  # I'm going to be abusing `{ ... }:` syntax as poor-woman's-typechecking.

  parseInput = flakeRefAttrs @ {
    ...
  }: if flakeRefAttrs ? url then
    parseFlakeRef flakeRefAttrs.url
  else removeAttrs flakeRefAttrs [
    "flake" # flake = false
    "inputs" # inputs.foo.follows
  ];

  fetchInput = spec @ {
    ...
  }: parseInput spec |> fetchTree;

  # Of the shape:
  # { nixpkgs = { url = "…"; }; lix-module = { inputs = { … }; url = "…"}; … }
  flakeInputs = (import ../flake.nix).inputs;

  # Of the shape { nixpkgs = { outPath = "/nix/store/…"; rev = "…"; … }; log2compdb = …; }
  fetchedInputs = mapAttrs (_: spec @ { ... }: fetchInput spec) flakeInputs;

  getter = explicitInputs @ { ... }: let
    validNames = attrNames flakeInputs;
    givenButInvalidNames = attrNames (removeAttrs explicitInputs validNames);
    errorNames = concatStringsSep ", " givenButInvalidNames;
  in if givenButInvalidNames != [ ] then
    throw "attempted to override flake inputs that don't exist: \"${errorNames}\""
  else
    assert givenButInvalidNames == [ ];
    fetchedInputs // explicitInputs;

in getter
