{
  inputs,
  lib,
  nixosConfigurations,
  darwinConfigurations,
}: let
  systemOf = cfg: cfg.pkgs.stdenv.hostPlatform.system;

  systemProfile = {
    user = "root";
    sshUser = "deploy";
    sshOpts = ["-i" "~/.ssh/deploy_key" "-o" "IdentitiesOnly=yes"];
  };

  mkNixosProfile = cfg:
    systemProfile // {path = inputs.deploy-rs.lib.${systemOf cfg}.activate.nixos cfg;};

  mkDarwinProfile = cfg:
    systemProfile // {path = inputs.deploy-rs.lib.${systemOf cfg}.activate.darwin cfg;};

  allHostnames = lib.unique (
    lib.attrNames nixosConfigurations ++ lib.attrNames darwinConfigurations
  );

  mkNode = name: let
    nixosConfig = nixosConfigurations.${name} or null;
    darwinConfig = darwinConfigurations.${name} or null;
  in {
    hostname = name;
    profiles =
      lib.optionalAttrs (nixosConfig != null) {nixos = mkNixosProfile nixosConfig;}
      // lib.optionalAttrs (darwinConfig != null) {darwin = mkDarwinProfile darwinConfig;};
  };

  deploy = {
    interactiveSudo = false;
    fastConnection = false;
    remoteBuild = true;
    magicRollback = true;
    autoRollback = true;
    nodes = lib.genAttrs allHostnames mkNode;
  };
in {
  inherit deploy;

  checks =
    builtins.mapAttrs (
      system: deployLib: let
        nodeSystemOf = name:
          systemOf (nixosConfigurations.${name} or darwinConfigurations.${name});
      in
        deployLib.deployChecks {
          inherit (deploy) magicRollback autoRollback interactiveSudo fastConnection remoteBuild;
          nodes = lib.filterAttrs (name: _: nodeSystemOf name == system) deploy.nodes;
        }
    )
    inputs.deploy-rs.lib;
}
