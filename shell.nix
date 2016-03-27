{ compiler ? "ghc" }:
let pkgs = import <nixpkgs> {};
    mynix = import <mynix>;
    haskellBuildTools = [ mynix.ghcDefault
                          mynix.cabalDefault ];

in pkgs.callPackage ./default.nix {
   inherit pkgs haskellBuildTools;
}
