{
  description = "Builds vesc tool from source";
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };
  
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        vesc-tool = pkgs.stdenv.mkDerivation {
          pname = "vesc-tool";
          version = "git";

          meta = with pkgs.lib; {
            description = "VESC Tool";
            platforms = platforms.linux;
          };
          
          desktopItem = pkgs.makeDesktopItem {
            name = "VESC Tool";
            exec = "vesc_tool";
            icon = "neutral_v.svg";
            comment = "Hello :)";
            desktopName = "VESC Tool";
            genericName = "Integrated Development Environment";
            categories = [ "Development" ];
          };

          src = pkgs.fetchFromGitHub {
            owner = "vedderb";
            repo = "vesc_tool";
            rev = "e4fcfe3";
            hash = "sha256-McovpqvgwGzFM5wYcNoHnWe7lBRPmy0KZ+DrYaK5qgo=";
          };
          
          # This is great :D
          patches = [
            ./res_fw.patch
          ];
          
          configurePhase = ''
            qmake -config release "CONFIG += release_lin build_original"
          '';
          buildPhase = ''
            make -j8
          '';
          installPhase = ''
            mkdir -p $out/bin
            mkdir -p $out/share/icons
            mkdir -p $out/share/application
            
            cp build/lin/vesc_tool_6.05 $out/bin/vesc_tool
            cp res/version/neutral_v.svg $out/share/icons/
            
            # mkdir -p $out/share/applications
            # echo "[Desktop Entry]
            #   Version=1.0
            #   Icon=$out/share/icons/neutral_v.svg
            #   Exec=$out/bin/vesc_tool
            #   Terminal=false
            #   Type=Application
            #   Name=VESC Tool
            #   Comment=VESC Tool" > $out/share/application/vesc_tool.desktop
          '';

          buildInputs = [ pkgs.libsForQt5.qtbase ];
          nativeBuildInputs = [
            pkgs.cmake
            pkgs.libsForQt5.qtbase
            pkgs.libsForQt5.qtquickcontrols2
            pkgs.libsForQt5.qtgamepad
            pkgs.libsForQt5.qtconnectivity
            pkgs.libsForQt5.qtpositioning
            pkgs.libsForQt5.qtserialport
            pkgs.libsForQt5.qtgraphicaleffects
            pkgs.libsForQt5.wrapQtAppsHook
            
            # Make the desktop icon work
            pkgs.copyDesktopItems
          ];
        };
      in rec {
        packages.default = vesc-tool;
      }
    );
}

# let
#   pkgs = import <nixpkgs> {};
# in
# pkgs.stdenv.mkDerivation rec {
#   pname = "vesc-tool";
#   version = "git";

#   meta = with pkgs.lib; {
#     description = "VESC Tool";
#   };

#   src = pkgs.fetchFromGitHub {
#     owner = "vedderb";
#     repo = "vesc_tool";
#     rev = "e4fcfe3";
#     hash = "sha256-McovpqvgwGzFM5wYcNoHnWe7lBRPmy0KZ+DrYaK5qgo=";
#   };
  
#   patches = [
#     ./res_fw.patch
#   ];
#   configurePhase = ''
#     qmake -config release "CONFIG += release_lin build_original"
#   '';
#   buildPhase = ''
#     make -j8
#   '';
#   installPhase = ''
#     mkdir -p $out/bin
#     cp build/lin/vesc_tool_6.05 $out/bin
#   '';

#   buildInputs = [ pkgs.libsForQt5.qtbase ];
#   nativeBuildInputs = [
#     pkgs.cmake
#     pkgs.libsForQt5.qtbase
#     pkgs.libsForQt5.qtquickcontrols2
#     pkgs.libsForQt5.qtgamepad
#     pkgs.libsForQt5.qtconnectivity
#     pkgs.libsForQt5.qtpositioning
#     pkgs.libsForQt5.qtserialport
#     pkgs.libsForQt5.qtgraphicaleffects
#     pkgs.libsForQt5.wrapQtAppsHook
#   ];
# }
