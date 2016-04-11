{ compiler ? "ghc" }:
let pkgs = import <nixpkgs> {};
    mynix = import <mynix>;
    haskellBuildTools = [ pkgs.haskell.packages.ghc7103
                          pkgs.haskell.packages.ghc7103.cabal-install ];

in pkgs.callPackage ./default.nix {
   inherit pkgs haskellBuildTools;
}
