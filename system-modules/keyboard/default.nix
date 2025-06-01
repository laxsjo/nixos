{ pkgs, ... }:

let
  # The content of `workman-se.xkb` was created by having the following configuration active and dumping it with `setxkbmap -print > some_file.xkb`
  # The only difference is the `partial` line and `xkb_symbols` block were added to replace `xkb_symbols { include "pc+ca(multi)+inet(evdev)+ctrl(swapcaps)+eurosign(e)+nbsp(none)" };`
  #   services.xserver = {
  #     # Set keyboard layout to Canadian Multilingual
  #     layout = "ca";
  #     xkbVariant = "multi";
  #     # AltGr + e for €, Swap Left Control and Caps Lock, AltGr + Space produces a normal space instead of a non-breakable space
  #     xkbOptions = "eurosign:e,ctrl:swapcaps,nbsp:none";
  #   };
  # ^ outdated
  xkbSymbols = ./workman-se.xkb;
in
{
  services.xserver = {
    enable = true;
    xkb = {
      layout = "se-workman";
      extraLayouts.se-workman = {
        description = "Swedish layout with workman letters";
        languages = [
          "eng"
          "swe"
        ];
        symbolsFile = xkbSymbols;
      };
    };
  };

  # Configure Kanata
  services.kanata = {
    enable = true;
    keyboards."layout".configFile = ./layout.kbd;
  };

  # Allows the uinput group to access keyboards via the uinput subsystem.
  # Usefull to run the Kanata CLI manually
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "uinput";
      destination = "/etc/udev/rules.d/99-uinput.rules";
      text = ''
        KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
      '';
    })
  ];
  # Add myself to the uinput group
  users.users."rasmus".extraGroups = [
    "uinput"
  ];
}
