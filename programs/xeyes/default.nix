# Tracks mouse movement whenever mouse moves over window using XWayland.
{
  lib,
  config,
  pkgs,
  ...
}:

let
  name = "xeyes";
  cfg = config.programs.${name};
in
{
  options = {
    programs.${name}.enable = lib.mkEnableOption "the xeyes utility program and desktop entry";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      xorg.xeyes
    ];

    xdg.desktopEntries = {
      ${name} = {
        name = "XEyes";
        genericName = "Mouse Follower";
        exec = "xeyes";
        # TODO: This feels kind of dirty...
        icon = ./icon.png;
        comment = "Eyes follows your cursor whenever they are above an application running XWayland.";
        categories = [ "Utility" ];
      };
    };

    programs.plasma.window-rules = [
      {
        description = "Keeps XEyes above other applications";
        match.window-class = {
          type = "substring";
          value = "XEyes";
        };

        apply = {
          "above" = {
            value = true;
            apply = "initially";
          };
        };
      }
    ];
  };
}
