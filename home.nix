{
  config,
  lib,
  pkgs,
  osConfig,
  inputs,
  ...
}:

{
  imports = builtins.break [
    ./modules/build-env.nix
    ./modules/shortcuts
    ./modules/shell
    ./modules/ssh
    ./modules/systemd.nix

    inputs.flatpak.homeManagerModules.nix-flatpak
    ./programs
  ];

  home.username = "rasmus";
  home.homeDirectory = "/home/rasmus";
  home.packages =
    with pkgs;
    [
      ## Terminal applications
      httpie
      # To debug wayland events, like key presses and mouse events.
      wev
      git
      kdotool
      lbm.repl
      lbm.repl64
      neofetch
      nixVersions.latest
      tree
      cowsay
      just
      jq
      xorg.xwininfo
      file
      bbe # binary file editor
      # See the following for an example:
      # https://discourse.nixos.org/t/debug-a-failed-derivation-with-breakpointhook-and-cntr/8669
      cntr # For debugging derivations in interactive containers
      nmap # For scanning active ports
      sshpass # For non-interactive password ssh/scp connections
      pv # Show progress for any command that can be piped.
      dust # Terminal folder size visualization
      reuse # Tool for working with the REUSE recommendations.
      usbutils
      direnv
      nix-direnv
      zip
      unzip
      openocd
      android-tools # To get adb for debugging Android phones.
      xsel # Utility for saving stdin to clipboard.
      htop # Modern alternative to top.

      ## Other
      man-pages
      man-pages-posix
      wayland-utils # To be able to use wayland-info in Info Center
      wineWowPackages.waylandFull # To be able to run windows EXEs.
      rustup # To make the rust-analyzer vscode extension work.

      ## GUI utils
      kdePackages.filelight

      ## Misc programs
      spotify
      discord
      obsidian
      google-chrome # Only for flasing moonlander keyboard
      filezilla
      vlc
      blender-hip
      obsidian
      geeqie # image viewer
      kooha # Image recorder
      ghostty # Terminal emulator
      geteduroam # Application for configuring eduroam network.
      bruno # API client

      ## Gaming
      prismlauncher # Minecraft launcher

      ## Editing programs
      (inkscape-with-extensions.override {
        inkscapeExtensions = [ inkscape-extensions.inkstitch ];
      })
      kicad
      krita
      pinta # Minimal image editor
      libreoffice-qt6 # LibreOffice Suite
      audacity # Audio manipulation
    ]
    ++ [
      inputs.gd-save-transfer.packages.${system}.default
      inputs.lolitop.packages.${system}.default
    ];

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "24.05";

  # Enable the general development dependencies
  module.build-env.enable = true;

  module.shortcuts.enable = true;
  module.shell.enable = true;
  module.ssh.enable = true;
  module.systemd.enable = true;

  ## Program configurations

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true; # This is probably not really necessary

  # Vim
  programs.vim = {
    enable = true;
  };

  # Sublime
  # home.file.".config/sublime-text/Packages/User/sublime-nix".source
  #   = pkgs.fetchFromGitHub {
  #     owner = "wmertens";
  #     repo = "sublime-nix";
  #     rev = "v2.3.2";
  #     hash = "sha256-1FfqlhPF5X+qwPxsw7ktyHKgH6VMKk0PV+LIXrGtbt4=";
  #   };

  # programs.steam = {
  #   enable = true;
  #   remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  #   dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  # };

  programs.normcap.enable = true;
  programs.xeyes.enable = true;
  programs.vesc-tool.enable = true;
  programs.vscode.enable = true;
  programs.linecut.enable = true;
  programs.rlr.enable = true;

  ## Flatpaks!
  # services.flatpak.enable = true;
  services.flatpak.uninstallUnmanaged = true;
  services.flatpak.update.onActivation = true;
  services.flatpak.packages = [
    {
      appId = "com.valvesoftware.Steam";
      origin = "flathub";
    }
    {
      appId = "app.zen_browser.zen";
      origin = "flathub";
    }
    {
      appId = "com.boxy_svg.BoxySVG";
      origin = "flathub";
    }
    {
      appId = "com.github.tchx84.Flatseal";
      origin = "flathub";
    }
    {
      appId = "io.mrarm.mcpelauncher";
      origin = "flathub";
    }
  ];
  services.flatpak.overrides = {
    "com.valvesoftware.Steam".Environment = {
      "STEAM_FORCE_DESKTOPUI_SCALING" = "1.5";
    };
  };
}
