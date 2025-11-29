{
  lib,
  pkgs,
  ...
}:

let
  imageMapRange =
    image: sourceColorStart: sourceColorEnd: destinationColorStart: destinationColorEnd:
    pkgs.stdenvNoCC.mkDerivation {
      name = "${image.name or builtins.baseNameOf image}.recolored.png";
      nativeBuildInputs = [ pkgs.imagemagick ];

      phases = [ "installPhase" ];
      installPhase = ''
        magick "${image}" \
          -level-colors "${sourceColorStart}":"${sourceColorEnd}" \
          -colorspace Gray \
          +level-colors "${destinationColorStart}":"${destinationColorEnd}" \
          PNG:$out
      '';
    };

  # Wallpapers by Sameera Sandakelum:
  # https://photos.app.goo.gl/vm9UudLFVqMrcyKW7
  loginBackground =
    imageMapRange ../assets/wallpapers/zen-coral-white-dim.jpeg "#F66E51" "white" "#BC97FF"
      "white";
  # Wallpaper from Garuda Mokka Theme
  # https://gitlab.com/garuda-linux/themes-and-settings/settings/garuda-mokka/-/blob/a5d2debff18475196588ed4a3e096197d74b4fac/wallpapers/
  desktopBackground = ../assets/wallpapers/River-city_Mocha.jpg;
in
{
  inherit loginBackground desktopBackground;
}
