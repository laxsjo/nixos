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
    programs.alacritty.enable = true;
    programs.alacritty.settings = {
      window = {
        opacity = 0.5;
        blur = true;
        decorations = "None";
        startup_mode = "Maximized";
      };

      terminal = {
        shell = "${config.programs.zellij.package}/bin/zellij";
      };

      general = {
        import = [
          "${inputs.catppuccin-alacritty}/${theme}.toml"
        ];
      };
    };
  };
}
