{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:

# This is pretty empty right now, but I anticepate needing more
# configurations soon :)

let
  name = "zed-editor";
in
{
  config = {
    home.packages = [
      # Building this took roughly 26 mins on my machine...
      inputs.zed.outputs.packages.${pkgs.system}.default
    ];
  };
}
