{ pkgs, ... }:

let
  # The content of `customKeyboardLayout` was created by having the following configuration active and dumping it with `setxkbmap -print > some_file.xkb`
  # The only difference is the `partial` line and `xkb_symbols` block were added to replace `xkb_symbols { include "pc+ca(multi)+inet(evdev)+ctrl(swapcaps)+eurosign(e)+nbsp(none)" };`
  #   services.xserver = {
  #     # Set keyboard layout to Canadian Multilingual
  #     layout = "ca";
  #     xkbVariant = "multi";
  #     # AltGr + e for €, Swap Left Control and Caps Lock, AltGr + Space produces a normal space instead of a non-breakable space
  #     xkbOptions = "eurosign:e,ctrl:swapcaps,nbsp:none";
  #   };
  # ^ outdated

  xkbSymbols = pkgs.writeText "se-workman" ''
    xkb_symbols "se-workman" {
      //include "se"
      include "pc+se+inet(evdev)"

      // Alphanumeric section
      key <AD01> {  [   q,  Q   ] };
      key <AD02> {  [   d,  D   ] };
      key <AD03> {  [   r,  R   ] };
      key <AD04> {  [   w,  W   ] };
      key <AD05> {  [   b,  B   ] };
      key <AD06> {  [   j,  J   ] };
      key <AD07> {  [   f,  F   ] };
      key <AD08> {  [   u,  U   ] };
      key <AD09> {  [   p,  P   ] };
      key <AD10> {  [   odiaeresis,  Odiaeresis   ] };
      key <AD11> {  [   aring,  Aring   ] };

      key <AC01> {  [   a,  A   ] };
      key <AC02> {  [   s,  S   ] };
      key <AC03> {  [   h,  H   ] };
      key <AC04> {  [   t,  T   ] };
      key <AC05> {  [   g,  G   ] };
      key <AC06> {  [   y,  Y   ] };
      key <AC07> {  [   n,  N   ] };
      key <AC08> {  [   e,  E   ] };
      key <AC09> {  [   o,  O   ] };
      key <AC10> {  [   i,  I   ] };
      key <AC11> {  [   adiaeresis,  Adiaeresis   ] };

      key <AB01> {  [   z,  Z   ] };
      key <AB02> {  [   x,  X   ] };
      key <AB03> {  [   m,  M   ] };
      key <AB04> {  [   c,  C   ] };
      key <AB05> {  [   v,  V   ] };
      key <AB06> {  [   k,  K   ] };
      key <AB07> {  [   l,  L   ] };
      
      // Doesn't work, it sends Shift+Delete, instead of just Delete :(
      // shift+backspace -> del
      //key <BKSP> {
      //  type= "TWO_LEVEL",
      //  symbols[Group1]= [ BackSpace, Delete ]
      //};
      
      // Make ',' and '.' keys behave like english keyboards.
      // Also swap ',' and '.' key order.
      key <AB08> {
        type= "FOUR_LEVEL",
        symbols[Group1]= [ period, greater, periodcentered, ellipsis ]
      };
      key <AB09> {
        type= "FOUR_LEVEL",
        symbols[Group1]= [ comma, less, dead_cedilla, dead_ogonek ]
      };
      key <LSGT> {
        type= "FOUR_LEVEL",
        symbols[Group1]= [ semicolon, colon, bar, brokenbar ]
      };
      
      // Make `, ^, and ~ not act as deadkey
      key <AE12> {
        type= "FOUR_LEVEL",
        symbols[Group1]= [      dead_acute,      grave,       plusminus,         notsign ]
      };
      key <AD12> {
          type= "FOUR_LEVEL",
          symbols[Group1]= [ dead_diaeresis, asciicircum, asciitilde, dead_caron ]
      };
    };
  '';
in
{
  services.xserver = {
    enable = true;
    xkb = {
      layout = "se-workman";
      extraLayouts.se-workman = {
        description = "Swedish layout with workman letters";
        languages   = [ "eng" "swe" ];
        symbolsFile = xkbSymbols;
      };
    };
  };

  # Configure the console keymap from the xserver keyboard settings
  #console.useXkbConfig = true; # TODO: May want?
}
