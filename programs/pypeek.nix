{ lib, config, pkgs, inputs, ... }:
# Only supported on X11 :(

let
  pname = "pypeek";
  version = "2.10.11";  
  # Override vesktop to use the standard discord icon
  pypeek = pkgs.python312Packages.buildPythonPackage {
    inherit pname version;
    pyproject = true;
    
    src = pkgs.fetchPypi {
      inherit pname version;
      sha256 = "sha256-Nd7VHD1CbyOALfV7TGeG157m/H7omvurOR8z7aSI8e0=";
    };
    build-system = with pkgs.python312Packages; [
      hatchling
    ];
    dependencies = with pkgs.python312Packages; [
      pyside6
      requests
      pkgs.ffmpeg_6
    ];
    doCheck = false;
  };
in {
  config = {
    home.packages = with pkgs; [
      pypeek
    ];
  };
}