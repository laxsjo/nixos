{ lib, config, pkgs, inputs, ... }:

let
  name = "normcap";
  cfg = config.programs.${name};
  
  icon = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/dynobo/normcap/6f5809c06d97896faf7ea61b05dbf16027777bf9/assets/resources/icons/normcap.svg";
    sha256 = "sha256:0lsjalks1i425xz75y2hapc17fx8zcf5gqc9ck4s2znhx0ygd4x3";
  };
in {
  options = {
    programs.${name}.enable = lib.mkEnableOption "the normcap program and desktop entry";
  };
  
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      normcap
    ];
    
    xdg.desktopEntries = {
      ${name} = {
        name = "NormCap";
        genericName = "Screenshot OCR Tool";
        exec = "normcap";
        icon = icon;
        comment = "OCR-powered screenshot tool to capture text instead of images.";
        categories = [ "Utility" ];
      };
    };
  };
}

  