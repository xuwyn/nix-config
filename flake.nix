{
  description = "NixOS + Home Manager Flake - Hyprland/Noctalia-v5 & i3/Polybar";

  # Binary caches
  nixConfig = {
    substituters = [
      "https://cache.nixos.org"
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
      "https://nyx-cache.chaotic.cx"
      "https://noctalia.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nyx-cache.chaotic.cx:dJxTrgMC3V3cFfyIiBQDQorG6k1LsqurH/srpMSq7qk="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix/master";

    nix-flatpak.url = "github:gmodena/nix-flatpak?ref=latest";

    # CachyOS kernel for gaming
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

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

    # quickshell lockscreens & more sddm themes
    qylock.url = "github:Darkkal44/qylock";

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    umbrella-fetch = {
      url = "github:ezequielgk/Umbrella-Fetch";
      flake = false;
    };

    mac-app-util.url = "github:hraban/mac-app-util";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    chaotic,
    alejandra,
    flake-utils,
    mac-app-util,
    nixos-wsl,
    ...
  } @ inputs: let
    overlays = import ./modules/overlays {inherit inputs;};

    mkNixosConfig = {
      system,
      host,
      profile,
      username,
      extraModules ? [],
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs overlays username host profile;};
        modules =
          [
            ./profiles/${profile}
          ]
          ++ extraModules;
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
          extraModules = [chaotic.nixosModules.default];
        };
        lettuce = mkNixosConfig {
          system = "x86_64-linux";
          host = "lettuce";
          profile = "wsl";
          username = "wyn";
          extraModules = [nixos-wsl.nixosModules.default];
        };
      };
      homeConfigurations = {
        "wyn@mango" = mkHomeConfig {
          system = "x86_64-linux";
          host = "mango";
          username = "wyn";
        };
        "wyn@lettuce" = mkHomeConfig {
          system = "x86_64-linux";
          host = "lettuce";
          username = "wyn";
        };
        "wyn@apricot" = mkHomeConfig {
          system = "aarch64-darwin";
          host = "apricot";
          username = "wyn";
          extraModules = [mac-app-util.homeManagerModules.default];
        };
        "wyn@capybara" = mkHomeConfig {
          system = "x86_64-linux";
          host = "capybara";
          username = "wyn";
          extraModules = [./hosts/capybara];
        };
        "wyn@potato" = mkHomeConfig {
          system = "x86_64-linux";
          host = "potato";
          username = "wyn";
          extraModules = [./hosts/potato];
        };
      };
    }
    // (flake-utils.lib.eachDefaultSystem (system: {
      formatter = alejandra.packages.${system}.default;
    }));
}
