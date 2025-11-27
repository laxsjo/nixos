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
      };

      general = {
        import = [
          "${inputs.catppuccin-alacritty}/${theme}.toml"
        ];
      };
    };
  };
}
