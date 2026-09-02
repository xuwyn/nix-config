{
  config,
  lib,
  ...
}: let
  categories = {
    nixosConfigurations = {
      specs = config.nixos // config.nixos-rpi;
      valueOf = cfg: cfg.config.system.build.toplevel;
    };
    darwinConfigurations = {
      specs = config.darwin;
      valueOf = cfg: cfg.config.system.build.toplevel;
    };
    homeConfigurations = {
      specs = config.home;
      valueOf = cfg: cfg.activationPackage;
    };
  };

  mkGroup = attr: cat:
    lib.foldl' (
      acc: name: let
        system = cat.specs.${name}.system;
        cfg = config.${attr}.${name};
      in
        acc // {${system} = (acc.${system} or {}) // {${name} = cat.valueOf cfg;};}
    ) {} (builtins.attrNames cat.specs);

  checks = lib.foldl' lib.recursiveUpdate {} (lib.mapAttrsToList mkGroup categories);
in {
  ciChecks = checks;
  ciMatrix = lib.concatMap (
    system: map (name: {inherit name system;}) (builtins.attrNames checks.${system})
  ) (builtins.attrNames checks);
}
