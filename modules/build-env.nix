# Globably installed build dependencies for external projects which I don't
# have control over, i.e. it's not feasible to turn them into flakes.
{ lib, config, pkgs, inputs, ... }:

let
  name = "build-env";
  cfg = config.module.${name};
in {
  options = {
    module.${name}.enable = lib.mkEnableOption "global build dependencies";
  };
  
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # For lbm repl
      gcc_multi
      readline
      gnumake
      graphviz
      
      # Temporary for gd-save-sync
      libmtp
    ];
  };
}