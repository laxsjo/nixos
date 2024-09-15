{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.4.1";
    flake-utils.url = "github:numtide/flake-utils";
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    vesc-tool-flake = {
      url = "github:laxsjo/vesc-tool-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      # Not specifying a hard commit makes nixos-rebuild (and other operations
      # that interact with the flake) always update the lock file to point to
      # the most recent commit for whatever reason...
      inputs.vesc-tool-src.url = "github:vedderb/vesc_tool/24754273b498d2dea78d5006a1c2e174b9d412da";
    };
    lispbm-flake = {
      url = "github:laxsjo/lispbm-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    gd-save-transfer = {
      url = "git+file:///home/rasmus/projects/github/gd-save-transfer";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    # cortex-xtop.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, flatpak, flake-utils, ... }: {
    nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = { inputs = inputs; };
      modules = [
        {
          nixpkgs.overlays = [
            inputs.lispbm-flake.overlays.default
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
  };
}
