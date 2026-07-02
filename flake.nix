{
  description = "NixOS configuration";

  inputs = {
    catppuccin-alacritty = {
      url = "git@github.com:catppuccin/alacritty.git";
      flake = false;
    };
    catppuccin-konsole = {
      url = "github:catppuccin/konsole";
      flake = false;
    };
    flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.6.0";
    flake-utils.url = "github:numtide/flake-utils";
    gd-save-transfer.url = "git+file:///home/rasmus/projects/github/gd-save-transfer";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    lispbm.url = "github:svenssonjoel/lispBM/master";
    lolitop.url = "github:cortex/lolitop";
    nixpkgs.url = "github:nixos/nixpkgs/release-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    treefmt-nix.url = "github:numtide/treefmt-nix";
    vesc-tool = {
      url = "github:Lindboard/vesc_tool/lind-fw-compat";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zed.url = "github:zed-industries/zed/v1.8.2";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      treefmt-nix,
      flatpak,
      flake-utils,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      pkgs-unstable = import nixpkgs-unstable { inherit system; };
      selfLib = import ./lib { inherit pkgs; };
      treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
    in
    rec {
      nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem rec {
        inherit system;
        specialArgs = { inherit inputs selfLib pkgs-unstable; };
        modules = [
          {
            nixpkgs.overlays = [
              inputs.lispbm.overlays.default
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
