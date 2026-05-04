{ pkgs, pkgs-unstable, ... }:

let
  mkFont = name: directory: pkgs.stdenv.mkDerivation {
    name = name;
    src = directory;
    nativeBuildInputs = [ pkgs-unstable.installFonts ];
  };
in
{
  fonts.packages = with pkgs; [
    fira-code
    nerd-fonts.fira-code
    libertine
    fira-sans
    inriafonts
    noto-fonts-cjk-sans # Includes Noto Sans Japanese
    noto-fonts-monochrome-emoji
    oldstandard
    montserrat
    bodoni-moda
  ] ++ [
    (mkFont "karrik" ../assets/fonts/karrik/fonts)
  ];
}