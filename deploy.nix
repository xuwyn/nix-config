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

  mkHomeProfile = home: {
    user = home.user;
    path = inputs.deploy-rs.lib.${home.config.pkgs.stdenv.hostPlatform.system}.activate.home-manager home.config;
  };

  isWSL = nixosConfig: nixosConfig.config.nixos.drivers.wsl.enable or false;
  nixosConfigAttrs = lib.filterAttrs (_: c: !isWSL c) config.nixosConfigurations;

  # TODO: check for system architecture
  homeConfigAttrs = lib.listToAttrs (map (name: let
    parts = lib.splitString "@" name;
  in {
    name = lib.last parts;
    value = {
      user = lib.head parts;
      config = config.homeConfigurations.${name};
    };
  }) (lib.attrNames config.homeConfigurations));

  primaryUser = usersAttrs:
    lib.head (lib.attrNames (lib.filterAttrs (_: u: builtins.elem "wheel" u.extraGroups) usersAttrs));

  mkNode = name: _: let
    nixosConfig = nixosConfigAttrs.${name} or null;
    darwinConfig = config.darwinConfigurations.${name} or null;
    homeConfig = homeConfigAttrs.${name} or null;
  in {
    hostname = name;
    sshUser =
      if nixosConfig != null
      then primaryUser nixosConfig.config.users.users
      else if darwinConfig != null
      then darwinConfig.config.system.primaryUser
      else homeConfig.user;
    profiles =
      lib.optionalAttrs (nixosConfig != null) {nixos = mkNixosProfile nixosConfig;}
      // lib.optionalAttrs (darwinConfig != null) {darwin = mkDarwinProfile darwinConfig;}
      // lib.optionalAttrs (homeConfig != null) {home = mkHomeProfile homeConfig;};
  };
in {
  deploy = {
    interactiveSudo = true; # non-root sshUser
    fastConnection = true;
    remoteBuild = true; # can't cross-compile anyway
    magicRollback = true;
    autoRollback = true;
    nodes = lib.mapAttrs mkNode (nixosConfigAttrs // config.darwinConfigurations);
  };

  # TODO: filter different architecture
  checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;
}
