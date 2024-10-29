{ lib, config, pkgs, inputs, ... }:

let
  name = "ssh";
  cfg = config.module.${name};
in {
  options = {
    module.${name}.enable = lib.mkEnableOption "ssh. You want to enable this. (Why did I even make this an option?)";
  };
  
  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      includes = [
        "${./config}"
      ];
    };
  };
}