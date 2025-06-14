{
  lib,
  pkgs,
  config,
  ...
}:

let
  name = "vscode";

  vscode-derivation = pkgs.vscode-fhs.overrideAttrs;

in
# vscode-runner =
{
  config = {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode-fhs;

      # extensions = [
      #   pkgs.vscode-extensions.jnoortheen.nix-ide
      # ];
      # userSettings = {
      #   "explorer.confirmDragAndDrop" = false;
      # };
      # ^ makes vscode break completely
    };
  };
}
