{ lib, pkgs, config, ... }:

# This is pretty empty right now, but I anticepate needing more
# configurations soon :)

let
  name = "zed-editor";
in {
  config = {
    home.packages = [
      pkgs.${name}
    ];
  };
}