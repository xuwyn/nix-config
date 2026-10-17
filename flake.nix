{
  # Binary caches
  nixConfig = {
    extra-substituters = [
      "https://umbriel.cachix.org"
      "https://noctalia.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.xinux.uz"
      "https://nixos-raspberrypi.cachix.org"
      "https://cache.nixos.org"
    ];
    extra-trusted-public-keys = [
      "umbriel.cachix.org-1:JfNq/2yg2S6D6z4Z2dVSZrZlDPQTKtexB6GAVLD98nw="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.xinux.uz:BXCrtqejFjWzWEB9YuGB7X2MV4ttBur1N8BkwQRdH+0="
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  outputs = args: let
    inputs = import ./.tack {overrides = args.tackOverrides or {};};
    inherit (inputs.nixpkgs) lib;

    systems = ["x86_64-linux" "aarch64-darwin" "aarch64-linux"];
    perSystem = f: lib.genAttrs systems (system: f inputs.nixpkgs.legacyPackages.${system} system);

    # Thanks iynaix! <3
    lamina = import ./lamina.nix {
      inherit inputs;
      inherit (args) self;
    };

    laminaOutputs = lamina.mkLaminaOutputs {
      modules = [./modules];
      overlays = import ./modules/_overlays {inherit inputs;};
      specialArgs = {
        users = ["wyn" "deploy"];
        flake.homeRelativePath = "nix-config";
      };

      nixos = {
        mango.tags = ["desktop" "nvidia" "amd"];
        # lettuce.tags = ["wsl"];
      };
      rpi.puffin.tags = ["rpi5" "server"];
      darwin.apricot.tags = ["desktop"];
    };

    deployOutputs = import ./deploy.nix {
      inherit inputs lib;
      inherit (laminaOutputs) nixosConfigurations darwinConfigurations;
    };

    ci = import ./ci.nix {
      inherit lib;
      inherit (laminaOutputs) nixosConfigurations darwinConfigurations;
    };

    wrapperModules = perSystem (pkgs: _: let
      inherit (inputs.adios) adios;
      sources = import ./_sources/generated.nix {
        inherit (pkgs) fetchFromGitHub fetchurl fetchgit dockerTools;
      };
      root.modules = adios.lib.inject [
        inputs.adios-wrappers.wrapperModules
        (adios.lib.importModules {
          directory = ./modules/_wrappers;
          args =
            adios
            // {
              flakeInputs = inputs;
              inherit sources;
            };
        })
      ];
    in
      (adios root {options."/nixpkgs" = {inherit pkgs;};}).modules);
  in {
    inherit (laminaOutputs) nixosConfigurations darwinConfigurations;
    inherit (deployOutputs) deploy checks;
    inherit (ci) ciChecks ciMatrix;
    inherit wrapperModules;

    formatter = perSystem (pkgs: _: pkgs.alejandra);
    wrappers = builtins.mapAttrs (_: builtins.mapAttrs (_: module: module {})) wrapperModules;
  };
}
