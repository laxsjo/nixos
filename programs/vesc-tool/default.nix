{ lib, config, pkgs, inputs, system, ... }:

let
  name = "vesc-tool";
  cfg = config.programs.${name};
  
  # vescToolDerivation = (pkgs.stdenv.mkDerivation 
  #   (let
  #     desktopItem = pkgs.makeDesktopItem {
  #       name = name;
  #       exec = "vesc_tool";
  #       icon = "neutral_v.svg";
  #       comment = "Hello :3";
  #       desktopName = "VESC Tool";
  #       genericName = "Integrated Development Environment";
  #       categories = [ "Development" ];
  #     };
  #   in {
  #     pname = name;
  #     version = "git";

  #     meta = with pkgs.lib; {
  #       description = "VESC Tool";
  #       platforms = platforms.linux;
  #     };

  #     src = pkgs.fetchFromGitHub {
  #       owner = "vedderb";
  #       repo = "vesc_tool";
  #       rev = "865fcb7eace56f9343d80b7a727cfd2d1a38fb7d";
  #       hash = "sha256-44kzJPXnVFzWJCbkiMpJ3urx5BpIXXGpNSoTPV1zi4w=";
  #     };

  #     # I have no idea why this is necessary :D
  #     patches = [
  #       ./res_fw.patch
  #     ];

  #     configurePhase = ''
  #       qmake -config release "CONFIG += release_lin build_original"
  #     '';
  #     buildPhase = ''
  #       make -j8
  #     '';
  #     installPhase = ''
  #       mkdir -p $out/bin
  #       mkdir -p $out/share/icons
  #       mkdir -p $out/share/applications
        
  #       cp build/lin/vesc_tool_* $out/bin/vesc_tool
  #       cp res/version/neutral_v.svg $out/share/icons/
  #       cp ${desktopItem}/share/applications/${name}.desktop $out/share/applications/
  #     '';

  #     buildInputs = [ pkgs.libsForQt5.qtbase ];
  #     nativeBuildInputs = [
  #       pkgs.cmake
  #       pkgs.libsForQt5.qtbase
  #       pkgs.libsForQt5.qtquickcontrols2
  #       pkgs.libsForQt5.qtgamepad
  #       pkgs.libsForQt5.qtconnectivity
  #       pkgs.libsForQt5.qtpositioning
  #       pkgs.libsForQt5.qtserialport
  #       pkgs.libsForQt5.qtgraphicaleffects
  #       pkgs.libsForQt5.wrapQtAppsHook
        
  #       # Make the desktop icon work
  #       pkgs.copyDesktopItems
  #     ];
  #   })
  # );
in {
  options = {
    programs.${name}.enable = lib.mkEnableOption "VESC Tool";
  };
  
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      vesc-tool
    ];
  };
}

