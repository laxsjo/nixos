# My modified version of the Breeze SDDM theme
{ pkgs, ... }:

let
  patched = pkgs.applyPatches {
    src = pkgs.kdePackages.plasma-desktop;
    patches = [
      ./breeze-no-dropshadow.patch
    ];
  };
in
pkgs.symlinkJoin {
  name = "breeze-clean";
  paths = [
    (pkgs.atPath "${patched}/share/sddm/themes/breeze" "share/sddm/themes/breeze-clean")
    (pkgs.atPath ./metadata.desktop "share/sddm/themes/breeze-clean/metadata.desktop")
  ];
}
