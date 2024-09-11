{ pkgs }:

pkgs.stdenv.mkDerivation (let
  name = "ww-run-raise";
  
in {
  pname = name;
  version = "";

  meta = with pkgs.lib; {
    description = "don't feel like describing :)";
    platforms = platforms.linux;
  };

  src = pkgs.fetchFromGitHub {
    # owner = "academo";
    # repo = "ww-run-raise";
    # rev = "97140781d27cabcc97000a135863df21fedbd472";
    # hash = "sha256-AavoAYkYlfOyfqOhDL5BvDv35fi+zPqsT4pausxeaxg=";
    # Use fork which has support for KDE 6 until it is merged into the original
    # repo. See https://github.com/academo/ww-run-raise/pull/8
    owner = "laxsjo";
    repo = "ww-run-raise-laxsjo";
    rev = "4ba946fdbf17e96b3dc999fb42a3a43d10ed83fa";
    hash = "sha256-NiToJGDLF24M1CwQIoVe5nsMQZDdFcZuq4OBwpMdAVM=";
  };

  # configurePhase = ''
  #   qmake -config release "CONFIG += release_lin build_original"
  # '';
  # buildPhase = ''
  #   make -j8
  # '';
  installPhase = ''
    mkdir -p $out/bin
    
    # remember to change from ww_kde6 -> ww after switching back from the fork 
    cp ww_kde6 $out/bin/ww
  '';
})
