{
  inputs,
  lib,
  config,
  self,
}: let
  mkNixosProfile = nixosConfig: {
    user = "root";
    path = inputs.deploy-rs.lib.${nixosConfig.pkgs.stdenv.hostPlatform.system}.activate.nixos nixosConfig;
  };

  mkDarwinProfile = darwinConfig: {
    user = "root";
    path =
      inputs.deploy-rs.lib.${darwinConfig.pkgs.stdenv.hostPlatform.system}.activate.custom
      darwinConfig.config.system.build.toplevel
      "./activate";
  };

  isWSL = nixosConfig: nixosConfig.config.nixos.drivers.wsl.enable or false;
  nixosConfigAttrs = lib.filterAttrs (_: c: !isWSL c) config.nixosConfigurations;

  primaryUser = usersAttrs:
    lib.head (lib.attrNames (lib.filterAttrs (_: u: builtins.elem "wheel" u.extraGroups) usersAttrs));

  mkNode = name: _: let
    nixosConfig = nixosConfigAttrs.${name} or null;
    darwinConfig = config.darwinConfigurations.${name} or null;
  in {
    hostname = name;
    sshUser =
      if nixosConfig != null
      then primaryUser nixosConfig.config.users.users
      else darwinConfig.config.system.primaryUser;
    profiles =
      lib.optionalAttrs (nixosConfig != null) {nixos = mkNixosProfile nixosConfig;}
      // lib.optionalAttrs (darwinConfig != null) {darwin = mkDarwinProfile darwinConfig;};
  };
in {
  deploy = {
    interactiveSudo = true; # openssh already limited
    fastConnection = true;
    remoteBuild = true; # can't cross-compile anyway
    magicRollback = true;
    autoRollback = true;
    nodes = lib.mapAttrs mkNode (nixosConfigAttrs // config.darwinConfigurations);
  };

  checks =
    builtins.mapAttrs (
      system: deployLib: let
        nodeSystemOf = name:
          if nixosConfigAttrs ? ${name}
          then nixosConfigAttrs.${name}.pkgs.stdenv.hostPlatform.system
          else config.darwinConfigurations.${name}.pkgs.stdenv.hostPlatform.system;
      in
        deployLib.deployChecks {
          inherit (self.deploy) magicRollback autoRollback interactiveSudo fastConnection remoteBuild;
          nodes = lib.filterAttrs (name: _: nodeSystemOf name == system) self.deploy.nodes;
        }
    )
    inputs.deploy-rs.lib;
}
