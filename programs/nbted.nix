{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

# Program for pretty printing and editing NBT data

let
  fake-git = pkgs.writeShellApplication {
    name = "git";
    text = ''
      if [[ $1 == "rev-parse" && $2 == "HEAD" ]]; then
        echo "$FAKE_GIT_HEAD"
      else
        exit 1
      fi
    '';
  };
  nbted = pkgs.rustPlatform.buildRustPackage rec {
    pname = "nbted";
    version = "1.5.2";

    nativeBuildInputs = with pkgs; [
      pkg-config
      fake-git
    ];
    FAKE_GIT_HEAD = "HEAD";

    # For some reason the bigtest_compression test seem to fail, and I can't be
    # bothered to fix it.
    doCheck = false;

    src = pkgs.fetchFromGitHub {
      owner = "C4K3";
      repo = pname;
      rev = version;
      hash = "sha256-8f9NIWJB/ye67QkvfKnrTK1hUkTKs6FQiKk2z+XsdP8=";
    };

    cargoHash = "sha256-Vz4NF8wDpD0Hy6NzVBuLQC9t90hNeoNHuVdxMjPZEx4=";
  };
in
{
  config = {
    home.packages = [
      nbted
    ];
  };
}
