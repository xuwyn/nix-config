{
  description = "nixos+home: hyprland+noctalia/dms & i3+polybar";

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

  outputs = args: let
    inputs = import ./.tack {overrides = args.tackOverrides or {};};
    inherit (inputs.nixpkgs) lib;

    systems = ["x86_64-linux" "aarch64-darwin"];
    perSystem = f: lib.genAttrs systems (system: f inputs.nixpkgs.legacyPackages.${system} system);

    buildsPerSystem = system:
      lib.mapAttrs' (
        name: _:
          lib.nameValuePair "${name}"
          config.nixosConfigurations.${name}.config.system.build.toplevel
      ) (lib.filterAttrs (name: _: config.nixosConfigurations.${name}.config.nixpkgs.hostPlatform.system == system) config.nixos)
      // lib.mapAttrs' (
        name: _:
          lib.nameValuePair "${name}"
          config.homeConfigurations.${name}.activationPackage
      ) (lib.filterAttrs (name: cfg: cfg.system == system) config.home);

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

    formatter = perSystem (pkgs: _: pkgs.alejandra);
    checks = perSystem (_: system: buildsPerSystem system);
    packages = perSystem (_: system: buildsPerSystem system);

    devShells = perSystem (pkgs: _: {
      python = pkgs.mkShell {
        packages = with pkgs; [
          python3
          python3Packages.pip
          python3Packages.virtualenv
          python3Packages.setuptools
          python3Packages.black
          python3Packages.flake8
          python3Packages.mypy
          python3Packages.requests
        ];

        shellHook = ''
          export PIP_USER=1
        '';
      };
    });
  };
}
