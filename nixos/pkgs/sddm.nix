{ pkgs }:

pkgs.sddm.overrideAttrs (finalAttrs: prevAttrs: {
  propagatedBuildInputs = prevAttrs.propagatedBuildInputs ++ [
    pkgs.weston
  ];
})
