# My modified version of the Breeze SDDM theme
{ pkgs, ... }:

let
  patched = pkgs.applyPatches {
    src = pkgs.kdePackages.plasma-desktop;
    patches = [
      ./breeze-metadata.patch
      ./breeze-no-dropshadow.patch
    ];
  };
in
  pkgs.atPath
    "${patched}/share/sddm/themes/breeze"
    "share/sddm/themes/breeze-clean"
