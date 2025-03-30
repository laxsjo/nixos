# Configuration for systemd related tools
{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  name = "systemd";
  cfg = config.module.${name};
in
{
  options = {
    module.${name}.enable = lib.mkEnableOption "configuration of systemd related tools";
  };

  config = lib.mkIf cfg.enable {
    module.shell.sessionVariables = {
      # Tell journalctl to not pass unwanted options, namely:
      # -X: Keep the output visible after quiting.
      # -F: Don't enter pager if output is less than a page.
      "SYSTEMD_LESS" = "RSM";
    };
  };
}
