# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  ...
}:
let
  oryx = (pkgs.callPackage ./system-modules/oryx.nix { });
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./system-modules/keyboard.nix
    ./system-modules/kde
    ./system-modules/cachix.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel version
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  # services.xserver.enable = true;

  # Configure keymap in X11
  #   services.xserver = {
  #     # enable = true;
  #     exportConfiguration = true; # link /usr/share/X11/ properly
  #     xkb = {
  #       layout = "se";
  #       variant = "workman,";
  #     };
  #   };

  # Configure console keymap
  #console.keyMap = "sv-latin1";
  #console.useXkbConfig = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable autodiscovery of network printers.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # idk where this belongs, to make sure that editing admin files in sublime works
  security.polkit.enable = true;
  # Set sudo password timeout to 2 hours.
  security.sudo.extraConfig =
    let
      timeoutMins = 120;
    in
    ''
      Defaults        timestamp_timeout=${builtins.toString (timeoutMins * 60)}
    '';

  # Is this enabled by default? *thinking-emoji*
  # Previously known as hardware.opengl.enable
  hardware.graphics = {
    enable = true;
  };
  hardware.amdgpu = {
    opencl.enable = true;
    # IDK if this actually changed anything.
    amdvlk.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  users.groups = {
    "plugdev" = { };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rasmus = {
    isNormalUser = true;
    description = "Rasmus Söderhielm";
    # I'm not sure if I'm supposed to be a member of the plugdev group...
    extraGroups = [
      "networkmanager"
      "wheel"
      "dialout"
      "plugdev"
      "docker"
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      kdePackages.kate
    ];
  };
  # users.extraUsers.rasmus = {
  #   shell = pkgs.zsh;
  # };

  # Install docker
  virtualisation.docker.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  nixpkgs.config = {
    # Allow unfree packages
    allowUnfree = true;

    # Allow unsafe packages
    permittedInsecurePackages = [
      "openssl-1.1.1w" # For sublime4
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    gedit
    xorg.setxkbmap
    xorg.xkbcomp
    cntr
  ];

  # Enable flatpaks
  services.flatpak.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    fira-code
    nerd-fonts.fira-code
  ];

  # Nix configuration
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Make shells available
  programs.zsh.enable = true;
  # environment.shells = with pkgs; [ zsh ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Enable bluetooth
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # udev rules
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "misc_rules";
      destination = "/etc/udev/rules.d/99-misc-rules.rules";
      text = ''
        # For ESP32c3
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1001", \
          MODE:="0667", \
          SYMLINK+="esp32c3_%n"

        # For the Brother PTouch
        SUBSYSTEM=="usb", ATTR{idVendor}=="04f9", ATTR{idProduct}=="2060",MODE:="0667",SYMLINK+="ptouch_%n"

        # For the Framework 16 Keyboard
        SUBSYSTEM=="usb", ATTR{idVendor}=="32ac", ATTR{idProduct}=="0018", MODE:="0660", GROUP="plugdev"
      '';
    })
    (pkgs.writeTextFile {
      name = "android";
      destination = "/etc/udev/rules.d/99-android.rules";
      text = ''
        ## For debugging android phones

        # Google Pixel 7 Pro
        # (IDK, this rule might also apply to more google products...)
        SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE:="0660", GROUP="plugdev"
      '';
    })
    oryx
  ];

  # TODO: move to better place
  boot.binfmt.emulatedSystems = [ "i686-linux" ];

  # Enable polkit (might be necessary for vscode to be able to use sudo in terminal?)
  # security.polkit.enable = true; # Was already enabled apparently...

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
