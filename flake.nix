{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-25.11";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.6.0";
    flake-utils.url = "github:numtide/flake-utils";
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    vesc-tool = {
      url = "github:vedderb/vesc_tool/master";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lispbm = {
      url = "github:svenssonjoel/lispBM/master";
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
    zed = {
      url = "github:zed-industries/zed/v0.179.4";
    };
    catppuccin-konsole = {
      url = "github:catppuccin/konsole";
      flake = false;
    };
    catppuccin-alacritty = {
      url = "git@github.com:catppuccin/alacritty.git";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      treefmt-nix,
      flatpak,
      flake-utils,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      selfLib = import ./lib { inherit pkgs; };
      treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
    in
    rec {
      nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem rec {
        inherit system;
        specialArgs = { inherit inputs selfLib; };
        modules = [
          {
            nixpkgs.overlays = [
              inputs.lispbm.overlays.default
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

      formatter.${system} = treefmtEval.config.build.wrapper;
      checks.${system} = {
        formatting = treefmtEval.config.build.check self;
      };

      # For debugging
      inherit self;
    };
}
