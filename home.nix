{ config, lib, pkgs, osConfig, inputs, ... }:

{
  imports = [
    ./modules/build-env.nix
    ./modules/shell
    ./modules/shortcuts
    
    inputs.flatpak.homeManagerModules.nix-flatpak
    inputs.plasma-manager.homeManagerModules.plasma-manager
    ./programs/normcap.nix
    ./programs/xeyes
    ./programs/plasma
    ./programs/vesc-tool
    ./programs/vscode.nix
    ./programs/linecut
  ];
  
  home.username = "rasmus";
  home.homeDirectory = "/home/rasmus";
  home.packages = with pkgs; [
    ## Terminal applications
    httpie
    # To debug wayland events, like key presses and mouse events.
    wev
    git
    kdotool
    lbm
    lbm64
    nixVersions.latest
    
    ## Other
    man-pages
    man-pages-posix
    wayland-utils # To be able to use wayland-info in Info Center
    wineWowPackages.waylandFull # To be able to run windows EXEs.
    
    ## GUI utils
    kdePackages.filelight
    
    ## Misc programs
    sublime4 # Not using, but still keeping it around ¯\_(ツ)_/¯
    spotify
    discord
    enpass
    obsidian
    google-chrome # Only for flasing moonlander keyboard
    pinta # Minimal image editor
    filezilla
    inkscape
    vlc
    
    ## Gaming
    prismlauncher # Minecraft launcher
    
    ## Editing programs
    kicad
  ] ++ [
    inputs.gd-save-transfer.packages.${system}.default
  ];
  
  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "24.05";
  
  # Enable the general development dependencies
  module.build-env.enable = true;
  
  module.shortcuts.enable = true;
  module.shell.enable = true;
  
  ## Program configurations

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true; # This is probably not really necessary
  
  # Git
  programs.git = {
    enable = true;
    extraConfig = {
      user.name = "laxsjo";
      user.email = "rasmus.soderhielm@gmail.com";
      
      commit.gpgsign = true;
      gpg.format = "ssh";
      user.signingKey = "~/.ssh/id_ed25519";
      
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };
  
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
      appId = "io.github.zen_browser.zen";
      origin = "flathub";
    }
  ];
  services.flatpak.overrides = {
    "com.valvesoftware.Steam".Environment = {
      "STEAM_FORCE_DESKTOPUI_SCALING" = "1.5";
    };
  };
}
