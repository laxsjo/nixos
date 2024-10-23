{ lib, config, pkgs, inputs, ... }:

let
  # Override vesktop to use the standard discord icon
  vesktop-patched = pkgs.stdenv.mkDerivation rec {
    name = "${src.name}-patched";
    src = pkgs.vesktop;
    phases = [ "unpackPhase" "installPhase" ];
    installPhase = ''
      cp -r . $out
      
      rm -r $out/share/icons/hicolor/*
      
      mkdir -p $out/share/icons/hicolor/256x256/apps
      cp ${pkgs.discord}/share/icons/hicolor/256x256/apps/discord.png \
        $out/share/icons/hicolor/256x256/apps/vesktop.png
    '';
  };
  
  # pkgs.vesktop.overrideAttrs {
  #   postInstall = ''
  #     rm -r $out/share/icons/hicolor/*
  #     mkdir -p $out/share/icons/hicolor/256x256/apps
  #     cp ${pkgs.discord}/share/icons/hicolor/256x256/apps/discord.png \
  #       $out/share/icons/hicolor/256x256/apps/vesktop.png
  #   '';
  # };
in {
  config = {
    home.packages = with pkgs; [
      vesktop-patched # Custom discord client with support for wayland screen sharing
    ];
  };
}