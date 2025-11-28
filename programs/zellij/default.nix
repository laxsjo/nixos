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

    programs.zellij.settings = {
      # Apparently catppuccin comes preinstalled with zellij.
      inherit theme;

      show_startup_tips = false;
    };

    xdg.configFile."zellij/config.kdl".text =
      (builtins.readFile ./keybinds.kdl) + (lib.hm.generators.toKDL { } config.programs.zellij.settings);
  };
}
