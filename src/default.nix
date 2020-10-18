{ pkgs ? import <nixpkgs> {} }:

(pkgs.callPackage (import ./site.nix) {
  nixpkgs = pkgs;
}).site
