# Module that adds configuration options for specifying application shortcuts.
# This module structure is probably very cursed.
{ lib, config, pkgs, ... }:

let
  name = "shortcuts";
  cfg = config.module.${name};
in {
  options = with lib; {
    # module.${name}.enable = lib.mkEnableOption "global application shortcuts";
    module.${name}.shortcuts = mkOption {
      default = {};
      type = with types; attrsOf (submodule {
        options = {
          name = mkOption {
            type = str;
          };
          key = mkOption {
            type = str;
          };
          windowClass = mkOption {
            type = str;
          };
          process = mkOption {
            type = str;
          };
          exec = mkOption {
            type = str;
          };
        };
      });
    };
  };
  
  config = {
    home.packages = [
      (pkgs.callPackage ./ww-run-raise.nix { })
    ];
    
    programs.plasma.hotkeys.commands = builtins.mapAttrs
      (name: value: {
        name = value.name;
        key = value.key;
        command = ''ww -f "${value.windowClass}" -p "${value.process}" -c "${value.exec}"'';
      })
      cfg.shortcuts;
    
    # programs.plasma.hotkeys.commands = {
    #   "vscode" = {
    #     name = "Focus VSCode";
    #     key = "Meta+Ctrl+Alt+Shift+C";
    #     command = "ww -f Code -c code";
    #   };
    #   "browser" = {
    #     name = "Focus Zen Browser";
    #     key = "Meta+Ctrl+Alt+Shift+B";
    #     command = ''
    #       ww -f zen-alpha -p zen -c "flatpak run --branch=stable --arch=x86_64 --command=launch-script.sh --file-forwarding io.github.zen_browser.zen"
    #     '';
    #   };
    # };
  };
}