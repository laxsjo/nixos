{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

{
  config = {
    home.packages = [
      pkgs.enpass
    ];

    xdg.autostart.enable = true;
    xdg.autostart.entries = [
      "${pkgs.enpass}/share/applications/enpass.desktop"
    ];
  };
}
