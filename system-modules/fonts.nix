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
    bodoni-moda
    eb-garamond
    fira-code
    fira-sans
    garamond-libre
    inriafonts
    libertine
    lora
    montserrat
    nerd-fonts.fira-code
    noto-fonts-cjk-sans # Includes Noto Sans Japanese
    noto-fonts-monochrome-emoji
    oldstandard
    sn-pro
  ] ++ [
    (mkFont "karrik" ../assets/fonts/karrik/fonts)
  ];
}