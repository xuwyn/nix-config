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
    path = inputs.deploy-rs.lib.${darwinConfig.pkgs.stdenv.hostPlatform.system}.activate.darwin darwinConfig;
  };

  isWSL = nixosConfig: nixosConfig.config.nixos.drivers.wsl.enable or false;
  nixosConfigAttrs = lib.filterAttrs (_: c: !isWSL c) config.nixosConfigurations;

  mkNode = name: _: let
    nixosConfig = nixosConfigAttrs.${name} or null;
    darwinConfig = config.darwinConfigurations.${name} or null;
  in {
    hostname = name;
    sshUser = "deploy";
    sshOpts = ["-i" "~/.config/sops-nix/secrets/deploy_key" "-o" "IdentitiesOnly=yes"];
    profiles =
      lib.optionalAttrs (nixosConfig != null) {nixos = mkNixosProfile nixosConfig;}
      // lib.optionalAttrs (darwinConfig != null) {darwin = mkDarwinProfile darwinConfig;};
  };
in {
  deploy = {
    interactiveSudo = false; # deploy has NOPASSWD sudo
    fastConnection = true;
    remoteBuild = true;
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
