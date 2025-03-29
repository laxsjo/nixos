{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.6.0";
    flake-utils.url = "github:numtide/flake-utils";
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    vesc-tool = {
      url = "github:vedderb/vesc_tool/master";
      flake = false;
    };
    vesc-tool-flake = {
      # url = "git+file:///home/rasmus/Lind/vesc-tool-flake";
      url = "github:laxsjo/vesc-tool-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.src.follows = "vesc-tool";
    };
    lispbm = {
      url = "github:svenssonjoel/lispBM/master";
      flake = false;
    };
    lispbm-flake = {
      url = "github:laxsjo/lispbm-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.lispbm-src.follows = "lispbm";
    };
    gd-save-transfer = {
      url = "git+file:///home/rasmus/projects/github/gd-save-transfer";
    };
    lolitop = {
      url = "github:cortex/lolitop";
      # url = "git+file:///home/rasmus/projects/github/xtop-laxsjo";
    };
    ghostty = {
      url = "github:ghostty-org/ghostty";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, flatpak, flake-utils, ... }: rec {
    nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        {
          nixpkgs.overlays = [
            inputs.vesc-tool-flake.overlays.default
            inputs.lispbm-flake.overlays.default
            inputs.ghostty.overlays.default
            (import ./overlay.nix)
          ];
        }
        ./configuration.nix
        flatpak.nixosModules.nix-flatpak
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.rasmus = import ./home.nix;

          # Optionally, use home-manager.extraSpecialArgs to pass arguments to
          # home.nix
          home-manager.extraSpecialArgs.inputs = inputs;
          home-manager.extraSpecialArgs.system = system;
        }
      ];
    };
    
    # For debugging
    inherit self;
  };
}
