{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  name = "emote";
in
{
  config = {
    home.packages = [
      pkgs.${name}
    ];

    programs.plasma.shortcuts = {
      # Disable shortcut to KDE's default emoji picker
      "services/org.kde.plasma.emojier.desktop"."_launch" = [ ];

      "services/com.tomjwatson.Emote.desktop"."_launch" = [
        "Meta+."
        "Meta+Ctrl+Alt+Shift+Space"
      ];
    };
  };
}
