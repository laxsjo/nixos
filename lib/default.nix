{ pkgs }:

let
  lib = pkgs.lib;
in
{
  wallpaper = import ./wallpaper.nix { inherit lib pkgs; };
}
