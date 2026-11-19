{ nixpkgs, ... }:
final: prev:
let
  inherit (final) lib;
in
{
  pkgsStaticOptimised = import nixpkgs {
    inherit (final.stdenv) system;
    overlays = [
      (
        self': super':
        {
          pkgsStaticOptimised = super';
        }
        // lib.optionalAttrs super'.stdenv.hostPlatform.isMusl {
          pkgsMusl = super';
        }
      )
    ];
    config.replaceCrossStdenv = (
      { buildPackages, baseStdenv }:
      buildPackages.stdenvAdapters.withCFlags [ "-flto" "-Os" ] baseStdenv
    );

    crossSystem = {
      isStatic = true;
      config = lib.systems.parse.tripleFromSystem (
        if final.stdenv.hostPlatform.isLinux then
          lib.systems.parse.mkMuslSystem final.stdenv.hostPlatform.parsed
        else
          final.stdenv.hostPlatform.parsed
      );
      gcc =
        lib.optionalAttrs (final.stdenv.hostPlatform.system == "powerpc64-linux") { abi = "elfv2"; }
        // final.stdenv.hostPlatform.gcc or { };
    };
  };
}
