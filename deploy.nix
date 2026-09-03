{
  inputs,
  lib,
  config,
  self,
}: let
  systemProfile = {
    user = "root";
    sshUser = "deploy";
    sshOpts = ["-i" "~/.config/sops-nix/secrets/deploy_key" "-o" "IdentitiesOnly=yes"];
  };

  mkNixosProfile = nixosConfig:
    systemProfile // {path = inputs.deploy-rs.lib.${nixosConfig.pkgs.stdenv.hostPlatform.system}.activate.nixos nixosConfig;};

  mkDarwinProfile = darwinConfig:
    systemProfile // {path = inputs.deploy-rs.lib.${darwinConfig.pkgs.stdenv.hostPlatform.system}.activate.darwin darwinConfig;};

  # connect as the actual user, not `deploy` for home profile
  mkHomeProfile = homeConfig: {
    user = homeConfig.config.home.username;
    sshUser = homeConfig.config.home.username;
    path = inputs.deploy-rs.lib.${homeConfig.pkgs.stdenv.hostPlatform.system}.activate.home-manager homeConfig;
  };

  nixosConfigAttrs = config.nixosConfigurations;
  darwinConfigAttrs = config.darwinConfigurations;
  homeConfigAttrs = config.homeConfigurations or {};

  homeConfigHostname = name: lib.last (lib.splitString "@" name);
  homeConfigsByHost = lib.listToAttrs (map (name: {
    name = homeConfigHostname name;
    value = homeConfigAttrs.${name};
  }) (lib.attrNames homeConfigAttrs));

  allHostnames = lib.unique (
    lib.attrNames nixosConfigAttrs
    ++ lib.attrNames darwinConfigAttrs
    ++ lib.attrNames homeConfigsByHost
  );

  mkNode = name: let
    nixosConfig = nixosConfigAttrs.${name} or null;
    darwinConfig = darwinConfigAttrs.${name} or null;
    homeConfig = homeConfigsByHost.${name} or null;
  in {
    hostname = name;
    profiles =
      lib.optionalAttrs (nixosConfig != null) {nixos = mkNixosProfile nixosConfig;}
      // lib.optionalAttrs (darwinConfig != null) {darwin = mkDarwinProfile darwinConfig;}
      // lib.optionalAttrs (homeConfig != null) {home = mkHomeProfile homeConfig;};
  };
in {
  deploy = {
    interactiveSudo = false;
    fastConnection = false;
    remoteBuild = true;
    magicRollback = true;
    autoRollback = true;
    nodes = lib.genAttrs allHostnames mkNode;
  };
  # prevent flake check from checking incompatible platform
  checks =
    builtins.mapAttrs (
      system: deployLib: let
        nodeSystemOf = name:
          if nixosConfigAttrs ? ${name}
          then nixosConfigAttrs.${name}.pkgs.stdenv.hostPlatform.system
          else if darwinConfigAttrs ? ${name}
          then darwinConfigAttrs.${name}.pkgs.stdenv.hostPlatform.system
          else homeConfigsByHost.${name}.pkgs.stdenv.hostPlatform.system;
      in
        deployLib.deployChecks {
          inherit (self.deploy) magicRollback autoRollback interactiveSudo fastConnection remoteBuild;
          nodes = lib.filterAttrs (name: _: nodeSystemOf name == system) self.deploy.nodes;
        }
    )
    inputs.deploy-rs.lib;
}
