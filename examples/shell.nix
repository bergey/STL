{ pkgs ? import <nixpkgs> {}, haskellPackages ? pkgs.haskellPackages }:

let 
  tmpHaskellPkgs= haskellPackages.override {
        extension = self: super: {
          STL = self.callPackage ../. {};
          thisPackage = self.callPackage ./. {};
      };
    };
  in let
     haskellPackages = tmpHaskellPkgs;
     in pkgs.lib.overrideDerivation haskellPackages.thisPackage (attrs: {
       buildInputs = [ haskellPackages.cabalInstall ] ++ attrs.buildInputs;
 })
