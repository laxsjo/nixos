{ ... }:

{
  imports = [
    ./normcap.nix
    ./xeyes
    ./vesc-tool
    ./vscode.nix
    ./linecut
    ./discord.nix
    # This takes ages to build, and I don't think I use it.
    # ./pypeek.nix
    ./rlr.nix
    ./emote.nix
    ./zed-editor.nix
    ./git.nix
    ./nbted.nix
    ./gdb.nix
    ./enpass.nix
    ./alacritty.nix
    ./zellij
    ./typst-watch
  ];
}
