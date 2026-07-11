{
  description = "NixOS + Home Manager Flake - Hyprland/Noctalia-v5 & i3/Polybar";

  # Binary caches
  nixConfig = {
    substituters = [
      "https://cache.nixos.org"
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
      "https://noctalia.cachix.org"
      "https://cache.xinux.uz"
      "https://zed-industries.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "cache.xinux.uz:BXCrtqejFjWzWEB9YuGB7X2MV4ttBur1N8BkwQRdH+0="
      "zed-industries.cachix.org-1:fgVpvtdF+ssrgP1lB6EusuR3uM6bNcncWduKxri3u6Y="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/a799d3e3886da994fa307f817a6bc705ae538eeb";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-stable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    stylix.url = "github:danth/stylix/master";

    nix-flatpak.url = "github:gmodena/nix-flatpak?ref=latest";

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    matugen.url = "github:/InioX/Matugen";

    noctalia.url = "github:noctalia-dev/noctalia/cachix";

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland/v0.55.4";

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

    qylock.url = "github:Darkkal44/qylock";

    quickshell = {
      url = "github:quickshell-mirror/quickshell";
      inputs.nixpkgs.follows = "nixpkgs-stable";
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

  outputs = {nixpkgs, ...} @ inputs: let
    inherit (nixpkgs) lib;

    systems = ["x86_64-linux" "aarch64-darwin"];

    import-tree = dir:
      builtins.concatMap (
        elem: let
          path = dir + "/${elem}";
        in
          if (builtins.readDir dir).${elem} == "directory"
          then
            (
              if lib.hasPrefix "_" elem
              then []
              else import-tree path
            )
          else lib.optional (lib.hasSuffix ".nix" elem && !lib.hasPrefix "_" elem) path
      ) (builtins.attrNames (builtins.readDir dir));

    inherit
      (lib.evalModules {
        modules = import-tree ./modules;
        specialArgs = {inherit inputs;};
      })
      config
      ;
  in {
    inherit (config) nixosConfigurations homeConfigurations;

    formatter = lib.genAttrs systems (
      system: inputs.nixpkgs.legacyPackages.${system}.alejandra
    );

    checks = lib.genAttrs systems (
      system:
        lib.mapAttrs' (
          name: _:
            lib.nameValuePair "nixos-${name}"
            config.nixosConfigurations.${name}.config.system.build.toplevel
        ) (
          lib.filterAttrs (
            name: _:
              config.nixosConfigurations.${name}.config.nixpkgs.hostPlatform.system == system
          )
          config.nixos
        )
        // lib.mapAttrs' (
          name: _:
            lib.nameValuePair "home-${name}"
            config.homeConfigurations.${name}.activationPackage
        ) (lib.filterAttrs (name: cfg: cfg.system == system) config.home)
    );
  };
}
