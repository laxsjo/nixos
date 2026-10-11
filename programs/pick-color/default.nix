{
  lib,
  config,
  pkgs,
  ...
}:

let
  name = "pick-color";
  cfg = config.programs.${name};
  pick-color = pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = with pkgs; [
      kdePackages.spectacle
      imagemagick
      gnugrep
      wl-clipboard
    ];
    text = ''
      # Let the user select a region of the screen, average it down to a single
      # pixel, and copy that pixel's hex color to the clipboard.
      spectacle --region --nonotify --background --output /dev/stdout 2>/dev/null \
        | magick png:- -resize '1x1!' -format '%[pixel:p{0,0}]' txt:- \
        | grep -oE '#[0-9A-Fa-f]{6}' \
        | tr -d '\n' \
        | wl-copy
    '';
  };
in
{
  options = {
    programs.${name}.enable = lib.mkEnableOption "the pick-color screen color picker";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pick-color
    ];

    programs.plasma.hotkeys.commands.${name} = {
      name = "Pick Screen Color";
      comment = "Copy the color of a selected screen region to the clipboard.";
      key = "Meta+Shift+A";
      command = lib.getExe pick-color;
    };
  };
}
