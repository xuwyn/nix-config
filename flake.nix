{
  outputs = args: let
    inputs = import ./.tack {overrides = args.tackOverrides or {};};
    inherit (inputs.nixpkgs) lib;

    systems = ["x86_64-linux" "aarch64-darwin" "aarch64-linux"];
    perSystem = f: lib.genAttrs systems (system: f inputs.nixpkgs.legacyPackages.${system} system);

    overlays = import ./modules/_overlays {inherit inputs;};
    username = "wyn";
    flakePath = "nix-config"; # relative to $HOME

    # Thanks iynaix! <3
    lamina = import ./lib/lamina.nix {
      inherit inputs;
      inherit (args) self;
    };

    laminaOutputs = lamina.mkLaminaOutputs {
      modules = [./modules];
      inherit overlays;
      specialArgs = {
        users = [username "deploy"];
        inherit flakePath;
      };
      nixos = {
        mango.tags = ["desktop" "nvidia" "amd"];
        lettuce.tags = ["wsl"];
      };
      rpi.puffin.tags = ["rpi5" "server"];
      darwin.apricot.tags = ["desktop"];
      hjem."wyn@capybara".tags = ["desktop"];
    };

    deployOutputs = import ./deploy.nix {
      inherit inputs lib;
      inherit (laminaOutputs) nixosConfigurations darwinConfigurations;
    };

    ci = import ./ci.nix {
      inherit lib;
      inherit (laminaOutputs) nixosConfigurations darwinConfigurations;
    };

    wrapperModules = perSystem (_: system: let
      pkgs = import inputs.nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };
      inherit (inputs.adios) adios;
      root.modules = adios.lib.inject [
        inputs.adios-wrappers.wrapperModules
        (adios.lib.importModules {
          directory = ./modules/_wrappers;
          args =
            adios
            // {
              flakeInputs = inputs; # to differentiate from adios' inputs
              inherit username flakePath;
            };
        })
      ];
    in
      (adios root {options."/nixpkgs" = {inherit pkgs;};}).modules);
  in {
    inherit (laminaOutputs) nixosConfigurations darwinConfigurations hjemConfigurations;
    inherit (deployOutputs) deploy checks;
    inherit (ci) ciChecks ciMatrix;
    inherit wrapperModules;

    formatter = perSystem (pkgs: _: pkgs.alejandra);
    wrappers = builtins.mapAttrs (_: builtins.mapAttrs (_: module: module {})) wrapperModules;
  };
}
