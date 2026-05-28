{
  description = "ZaneyOS";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nvf.url = "github:notashelf/nvf";
    stylix.url = "github:danth/stylix/master";
    nix-flatpak.url = "github:gmodena/nix-flatpak?ref=latest";

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Checking nixvim to see if it's better
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Google Antigravity (IDE)
    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake/beta";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    alejandra = {
      url = "github:kamadorueda/alejandra";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    awww = {
     url = "git+https://codeberg.org/LGFae/awww";
     inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    nixvim,
    nix-flatpak,
    alejandra,
    ...
  } @ inputs: let
  mkNixosConfig = { system, host, profile, username }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs username host profile; };
      modules = [
        ./modules/core/overlays.nix
        ./profiles/${profile}
        nix-flatpak.nixosModules.nix-flatpak
      ];
    };

  mkHomeConfig = { system, host, profile, username }:
    home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = { inherit inputs username host profile; };
      modules = [
        ./modules/home
      ];
    };
  in {
    nixosConfigurations = {
      mango = mkNixosConfig {
        system = "x86_64-linux";
        host = "mango";
        profile = "amd-nvidia-hybrid";
        username = "wyn";
      };
    };

    homeConfigurations = {
      "wyn@mango" = mkHomeConfig {
        system = "x86_64-linux";
        host = "mango";
        profile = "amd-nvidia-hybrid";
        username = "wyn";
      };
    };

    formatter.x86_64-linux = inputs.alejandra.packages.x86_64-linux.default;
  };
}
