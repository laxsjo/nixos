{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  name = "ssh";
  cfg = config.module.${name};
  # Due to home manager shenanigans the symlink to ~/.ssh/config has incorrect permissions
  # (lrwxrwxrwx), which causes ssh inside FHS environment (such as in my VS Code setup) to
  # fail with 'Bad owner or permissions on /home/rasmus/.ssh/config'. This patch disables
  # that check in openssh.
  # source: https://github.com/nix-community/home-manager/issues/322#issuecomment-1178614454
  patchedOpenssh = pkgs.openssh.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./openssh.patch ];
    doCheck = false;
  });
in
{
  options = {
    module.${name}.enable =
      lib.mkEnableOption "ssh. You want to enable this. (Why did I even make this an option?)";
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      package = patchedOpenssh;

      includes = [
        "${./config}"
      ];
    };
  };
}
