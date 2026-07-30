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
      android-tools # To get adb for debugging Android phones.
      bbe # binary file editor
      # See the following for an example:
      # https://discourse.nixos.org/t/debug-a-failed-derivation-with-breakpointhook-and-cntr/8669
      cntr # For debugging derivations in interactive containers
      cowsay
      direnv
      dust # Terminal folder size visualization
      file
      git
      htop # Modern alternative to top.
      httpie
      jq
      just
      kdotool
      kittysay
      lbm.repl
      lbm.repl64
      neofetch
      nix-direnv
      nixos-rebuild-ng # nixos-rebuild rewrite
      nixVersions.latest
      nmap # For scanning active ports
      openocd
      pokemonsay
      pv # Show progress for any command that can be piped.
      reuse # Tool for working with the REUSE recommendations.
      sage # Interactive Python-based CAS environment
      sshpass # For non-interactive password ssh/scp connections
      tewisay
      tree
      unzip
      usbutils
      # To debug wayland events, like key presses and mouse events.
      wev
      xorg.xwininfo
      xsel # Utility for saving stdin to clipboard.
      zip

      ## Other
      man-pages
      man-pages-posix
      nil # Nix language server.
      rustup # To make the rust-analyzer vscode extension work.
      typstyle # Formatter for Typst
      wayland-utils # To be able to use wayland-info in Info Center
      wineWowPackages.waylandFull # To be able to run windows EXEs.

      ## GUI utils
      kdePackages.filelight

      ## Misc programs
      bambu-studio # Slicer for BambuLab 3D printers
      blender-hip
      bruno # API client
      burpsuite # Web application penetration testing application
      discord
      filezilla
      fontforge-gtk # Font editor
      geeqie # image viewer
      geteduroam # Application for configuring eduroam network.
      google-chrome # Only for flasing moonlander keyboard
      kooha # Image recorder
      obsidian
      spotify
      vlc

      ## Gaming
      openmw # Morrowind engine
      prismlauncher # Minecraft launcher

      ## Editing programs
      (inkscape-with-extensions.override {
        inkscapeExtensions = [ inkscape-extensions.inkstitch ];
      })
      audacity # Audio manipulation
      kicad
      krita
      libreoffice-qt6 # LibreOffice Suite
      pinta # Minimal image editor
    ]
    ++ [
      inputs.gd-save-transfer.packages.${stdenv.hostPlatform.system}.default
      inputs.lolitop.packages.${stdenv.hostPlatform.system}.default
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
