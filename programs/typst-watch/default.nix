{
  lib,
  config,
  pkgs,
  ...
}:

let
  name = "typst-watch";
  cfg = config.programs.${name};
  typst-watch = pkgs.writeScriptBin "typst-watch" (builtins.readFile ./typst-watch.sh);
in
{
  options = {
    programs.${name}.enable = lib.mkEnableOption "the typst-watch utility";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      typst-watch
      pkgs.typst
      pkgs.zathura
    ];
  };
}
