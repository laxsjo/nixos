# Globabl shortcuts to focus windows
{ lib, config, pkgs, ... }:

let
  name = "shortcuts";
  cfg = config.module.${name};
in {
  imports = [
    ./shortcuts.nix
  ];
  
  options = {
    module.${name}.enable = lib.mkEnableOption "global application shortcuts";
  };
  
  config = lib.mkIf cfg.enable {
    module.shortcuts.shortcuts = {
      "code-editor" = {
        name = "Focus VSCode";
        key = "Meta+Ctrl+Alt+Shift+C";
        windowClass = "Code";
        process = "code";
        exec = "code";
      };
      "browser" = {
        name = "Focus Zen Browser";
        key = "Meta+Ctrl+Alt+Shift+B";
        windowClass = "zen-alpha";
        process = "zen";
        exec = "flatpak run --branch=stable --arch=x86_64 --command=launch-script.sh --file-forwarding io.github.zen_browser.zen";
      };
    };
    # programs.plasma.window-rules = [
    #   {
    #     description = "Settings for VSCode";
    #     match.window-class = "Code";
    #     apply."shortcut" = {
    #       value = "Meta+Ctrl+Alt+Shift+C";
    #       apply = "force";
    #     };
    #   }
    # ];
  };
}