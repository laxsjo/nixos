# Installs grandMA3 through wine.
# It seem like downloading the installer zip fails with a 401 when the winema3
# flake tries to download it automatically. But you should be able to download
# it yourself from their website:
# https://www.malighting.com/downloads/products/grandma3/
# (Make sure to download version v2.3.2.0 as that is the version the flake
# expects.)
#
# Then when you have the ZIP file in your current directory, add it to your
# store with this command:
# ```
# nix store add-file grandMA3_onPC_win_v2.3.2.0.zip
# ```
#
# It must create the store path '/nix/store/6jdc65f1089ldx6fcfdnd5yw79sw5kci-grandMA3_onPC_win_v2.3.2.0.zip'!
#
# After it's been installed, you can load downloaded .show files from within the
# program by placing the files in this directory:
#   ~/.local/share/winema3/gma3_2.3.2/drive_c/ProgramData/MALightingTechnology/gma3_2.3.2/shared/shows/

{
  pkgs,
  inputs,
  ...
}:

{
  imports = [ inputs.winema3.nixosModules.default ];
  config = {
    programs.winema3 = {
      enable = true;
      # Makes its firewall settings always apply, instead of only when the
      # program is running (`launchMode = "on-demand"`). Using "on-demand"
      # enables a service which configures firewall rules which seems to be
      # broken. Using "always" disables that service.
      launchMode = "always";
      openFirewall = true;
      keepAwake = false;

      onpcPrefix = {
        enable = true;
        acceptEULA = true;
      };
    };
  };
}
