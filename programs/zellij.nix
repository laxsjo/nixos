{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  theme = "catppuccin-macchiato";
in
{
  config = {
    programs.zellij.enable = true;
    programs.zellij.enableZshIntegration = true;
    programs.zellij.attachExistingSession = true;

    programs.zellij.settings = {
      # Apparently catppuccin comes preinstalled with zellij.
      inherit theme;
    };
  };
}
