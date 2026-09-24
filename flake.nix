{
  # Binary caches
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.xinux.uz"
      "https://nixos-raspberrypi.cachix.org"
      "https://cache.nixos.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.xinux.uz:BXCrtqejFjWzWEB9YuGB7X2MV4ttBur1N8BkwQRdH+0="
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  outputs = args: let
    inputs = import ./.tack {overrides = args.tackOverrides or {};};
    inherit (inputs.nixpkgs) lib;
    inherit (lib) hasSuffix hasPrefix splitString filesystem genAttrs evalModules;
    inherit (builtins) any concatMap isPath filter readFileType;

    systems = ["x86_64-linux" "x86_64-darwin" "aarch64-darwin" "aarch64-linux"];
    perSystem = f: genAttrs systems (system: f inputs.nixpkgs.legacyPackages.${system} system);

    # Thanks llakala
    # https://github.com/llakala/synaptic-standard/blob/main/demo/recursivelyImport.nix
    expandIfFolder = elem:
      if !isPath elem || readFileType elem != "directory"
      then [elem]
      else
        filter
        (path: !any (hasPrefix "_") (splitString "/" (toString path)))
        (filesystem.listFilesRecursive elem);

    import-tree = list:
      filter
      (elem: !isPath elem || (hasSuffix ".nix" (toString elem) && !hasPrefix "_" (baseNameOf (toString elem))))
      (concatMap expandIfFolder list);

    inherit
      (evalModules {
        modules = import-tree [./modules];
        specialArgs = {
          inherit inputs;
          inherit (args) self;
        };
      })
      config
      ;

    wrapperModules = perSystem (pkgs: _: let
      inherit (inputs.adios) adios;
      root.modules = adios.lib.inject [
        inputs.adios-wrappers.wrapperModules
        (adios.lib.importModules {
          directory = ./modules/_wrappers;
          args = adios // {flakeInputs = inputs;};
        })
      ];
    in
      (adios root {options."/nixpkgs" = {inherit pkgs;};}).modules);
  in
    {
      inherit (config) nixosConfigurations darwinConfigurations homeConfigurations;
      inherit wrapperModules;
      formatter = perSystem (pkgs: _: pkgs.alejandra);
      wrappers = builtins.mapAttrs (_: builtins.mapAttrs (_: module: module {})) wrapperModules;
    }
    // import ./deploy.nix {
      inherit inputs lib config;
      inherit (args) self;
    }
    // import ./ci.nix {inherit config lib;};
}
