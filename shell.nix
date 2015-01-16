{ pkgs ? import <nixpkgs> {}, haskellPackages ? pkgs.haskellPackages }:

let 
  tmpHaskellPkgs= haskellPackages.override {
     extension = self: super: rec {
        hsPkg = pkg: version: self.callPackage "/home/bergey/code/nixHaskellVersioned/${pkg}/${version}.nix" {};
        bytestring = hsPkg "bytestring" "0.10.4.0";
        # cereal = self.callPackage /home/bergey/code/nixHaskellVersioned/cereal/0.4.1.0.nix {};
        attoparsec = hsPkg "attoparsec" "0.10.4.0";
        STL = self.callPackage ./. {};
      };
    };
  in let
     haskellPackages = tmpHaskellPkgs;
     in pkgs.lib.overrideDerivation haskellPackages.STL (attrs: {
       buildInputs = [ haskellPackages.cabalInstall ] ++ attrs.buildInputs;
 })
