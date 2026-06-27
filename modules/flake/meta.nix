{
  inputs,
  config,
  lib,
  ...
}: {
  imports = [inputs.flake-parts.flakeModules.modules];
  systems = ["x86_64-linux" "aarch64-darwin"];

  perSystem = {system, ...}: {
    formatter = inputs.alejandra.packages.${system}.default;
    checks =
      lib.optionalAttrs (system == "x86_64-linux") (
        lib.mapAttrs'
        (name: _:
          lib.nameValuePair "nixos-${name}"
          config.flake.nixosConfigurations.${name}.config.system.build.toplevel)
        config.nixos
      )
      // lib.mapAttrs'
      (name: _:
        lib.nameValuePair "home-${name}"
        config.flake.homeConfigurations.${name}.activationPackage)
      (lib.filterAttrs (name: cfg: cfg.system == system) config.home);
  };
}
