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
      pkgs.gdb
      # To access `telnet`, for connecting to an openocd REPL.
      pkgs.inetutils
    ];

    home.file.".gdbinit".text = ''
      # Enable loading of .gdbinit from any current directory.
      set auto-load local-gdbinit on
      set auto-load safe-path /
    '';
  };
}
