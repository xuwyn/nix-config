{
  description = "ZaneyOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:danth/stylix/master";
    nix-flatpak.url = "github:gmodena/nix-flatpak?ref=latest";

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell/v5";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf.url = "github:notashelf/nvf";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix formatter
    alejandra = {
      url = "github:kamadorueda/alejandra";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    hyprland.url = "github:hyprwm/Hyprland";

    zed = {
      url = "github:zed-industries/zed";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # encryption
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # for firefox addons
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # for custom addons not on NUR
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixcord.url = "github:FlameFlag/nixcord";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    silentSDDM = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    nixvim,
    nix-flatpak,
    alejandra,
    flake-utils,
    ...
  } @ inputs: let
    overlays = import ./modules/core/overlays.nix {inherit inputs;};

    mkNixosConfig = {
      system,
      host,
      profile,
      username,
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs overlays username host profile;};
        modules = [
          ./profiles/${profile}
        ];
      };

    mkHomeConfig = {
      system,
      host,
      profile,
      username,
    }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system overlays;
          config.allowUnfree = true;
        };
        extraSpecialArgs = {inherit inputs username host profile;};
        modules = [
          ./modules/home
        ];
      };
  in
    {
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
    }
    // (flake-utils.lib.eachDefaultSystem (system: {
      formatter = alejandra.packages.${system}.default;
    }));
}
