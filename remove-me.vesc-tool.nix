{ pkgs }:

pkgs.stdenv.mkDerivation (let
  name = "vesc_tool";
  desktopItem = pkgs.makeDesktopItem {
    name = name;
    exec = "vesc_tool";
    icon = "neutral_v.svg";
    comment = "Hello :3";
    desktopName = "VESC Tool";
    genericName = "Integrated Development Environment";
    categories = [ "Development" ];
  };
in {
  pname = "vesc-tool";
  # pname = abort "${desktopItem}";
  version = "git";

  meta = with pkgs.lib; {
    description = "VESC Tool";
    platforms = platforms.linux;
  };

  src = pkgs.fetchFromGitHub {
    owner = "vedderb";
    repo = "vesc_tool";
    rev = "5a1b9efe9812c449ac4d05e4e872d6e8700397cf";
    hash = "sha256-YeJSYgmSrDV4OG8+LXpcVK35y3jj4bloL3Mk4/Y96ZE=";
  };

  # This is great :D
  patches = [
    ./vesc-tool/res_fw.patch
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
    mkdir -p $out/share/applications
    
    cp build/lin/vesc_tool_* $out/bin/vesc_tool
    cp res/version/neutral_v.svg $out/share/icons/
    cp ${desktopItem}/share/applications/${name}.desktop $out/share/applications/
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
})
