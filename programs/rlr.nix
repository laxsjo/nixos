{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  name = "rlr";
  cfg = config.programs.${name};

  icon = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/dynobo/normcap/6f5809c06d97896faf7ea61b05dbf16027777bf9/assets/resources/icons/normcap.svg";
    sha256 = "sha256:0lsjalks1i425xz75y2hapc17fx8zcf5gqc9ck4s2znhx0ygd4x3";
  };
  rlr = pkgs.rustPlatform.buildRustPackage rec {
    pname = "rlr";
    version = "7bed0f3830f3506fadb5358bb36a4f8cb4da44e6";

    buildInputs = with pkgs; [
      pango
      atkmm
      gdk-pixbuf # Do I need this?
      gtk3 # This apparently provides gdk-3.0
    ];

    nativeBuildInputs = with pkgs; [
      pkg-config
      wrapGAppsHook
      glib.dev
    ];

    preBuild = ''
      mkdir -p \
        $out/share/glib-2.0/schemas/ \
        $out/share/applications/ \
        $out/share/icons/hicolor/scalable/apps/ \
        $out/share/icons/hicolor/symbolic/apps/

      cp data/com.github.epilys.rlr.Settings.gschema.xml \
        $out/share/glib-2.0/schemas/
      glib-compile-schemas $out/share/glib-2.0/schemas/

      cp data/com.github.epilys.rlr.desktop $out/share/applications/
      cp data/com.github.epilys.rlr.svg $out/share/icons/hicolor/scalable/apps/com.github.epilys.rlr.svg
      cp data/com.github.epilys.rlr-symbolic.svg $out/share/icons/hicolor/symbolic/apps/com.github.epilys.rlr.svg
    '';

    src = pkgs.fetchFromGitHub {
      owner = "epilys";
      repo = pname;
      rev = version;
      hash = "sha256-XF1owxyC1VjrTaAiK1XhZugIQ11v4JxrBBb8ZHV5DlA=";
    };

    cargoHash = "sha256-81GFc7qp0NNrw5oOHgfxghnMD4VQNY4AkyGmcdVFF4o=";
  };
in
{
  options = {
    programs.${name}.enable = lib.mkEnableOption "the rlr pixel screen ruler utility application";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      rlr
    ];

    dconf.settings = with lib.hm.gvariant; {
      "com/github/epilys/rlr" = {
        secondary-color = "rgba(12, 67, 88, 0.47)";
        primary-color = "#E8E8E8";
        font-size-factor = 1.5;
        window-opacity = 1.0;
      };
    };
  };
}
