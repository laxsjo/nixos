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
  };
}
