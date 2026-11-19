{
  lib,
  inputs,
}:
let
  pkgsStaticOptimisedOverlay = import ./pkgs-static-optimised.nix inputs;
  packagesOverlay = import ./packages.nix;
in
lib.composeManyExtensions [
  pkgsStaticOptimisedOverlay
  packagesOverlay
]
