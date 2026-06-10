{
  description = "NixOS - Hyprland + Noctalia-v5";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:danth/stylix/master";
    nix-flatpak.url = "github:gmodena/nix-flatpak?ref=latest";

    noctalia = {
      url = "github:noctalia-dev/noctalia";
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

    nix-ld = {
      url = "github:Mic92/nix-ld";
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

    umbrella-fetch = {
      url = "github:ezequielgk/Umbrella-Fetch";
      flake = false;
    };
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = {
    nixpkgs,
    home-manager,
    nixvim,
    nix-flatpak,
    alejandra,
    flake-utils,
    mac-app-util,
    ...
  } @ inputs: let
    overlays = import ./modules/overlays {inherit inputs;};

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
      username,
      extraModules ? [],
    }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system overlays;
          config.allowUnfree = true;
        };
        extraSpecialArgs = {inherit inputs username host;};
        modules =
          [
            ./modules/home
          ]
          ++ extraModules;
      };
  in
    {
      nixosConfigurations = {
        mango = mkNixosConfig {
          system = "x86_64-linux";
          host = "mango";
          profile = "amd-nvidia-sync";
          username = "wyn";
        };
      };

      homeConfigurations = {
        "wyn@mango" = mkHomeConfig {
          system = "x86_64-linux";
          host = "mango";
          username = "wyn";
        };
      };

      homeConfigurations = {
        "wyn@apricot" = mkHomeConfig {
          system = "aarch64-darwin";
          host = "apricot";
          username = "wyn";
          extraModules = [mac-app-util.homeManagerModules.default];
        };
      };
    }
    // (flake-utils.lib.eachDefaultSystem (system: {
      formatter = alejandra.packages.${system}.default;
    }));
}
