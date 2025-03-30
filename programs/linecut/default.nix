{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  name = "linecut";
  cfg = config.programs.${name};
  linecut = pkgs.writeScriptBin "linecut" (builtins.readFile ./linecut.sh);
in
{
  options = {
    programs.${name}.enable = lib.mkEnableOption "the linecut CLI utility";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      linecut
    ];
  };
}
