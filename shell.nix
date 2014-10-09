{ pkgs ? import <nixpkgs> {}, haskellPackages ? pkgs.haskellPackages }:

let 
  tmpHaskellPkgs= haskellPackages.override {
        extension = self: super: {
        bytestring = self.callPackage /home/bergey/code/nixHaskellVersioned/bytestring/0.10.4.0.nix {};
        cereal = self.callPackage /home/bergey/code/nixHaskellVersioned/cereal/0.4.1.0.nix {};
        STL = self.callPackage ./. {};
      };
    };
  in let
     haskellPackages = tmpHaskellPkgs;
     in pkgs.lib.overrideDerivation haskellPackages.STL (attrs: {
       buildInputs = [ haskellPackages.cabalInstall ] ++ attrs.buildInputs;
 })
