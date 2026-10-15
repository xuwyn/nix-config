{
  platforms = ["linux"];
  module = {
    config,
    lib,
    inputs,
    users,
    system,
    ...
  }: let
    activateRsCommand = "/nix/store/*/activate-rs";
    canaryRmGlob = "/tmp/deploy-rs-canary-*";

    systemUsers = config.custom.users;
    deployers = lib.filterAttrs (_: u: u.isDeployer) systemUsers;
  in {
    assertions = [
      {
        assertion = systemUsers ? deploy;
        message = ''
          deploy-rs requires a user named "deploy" to be declared in
          this host's users, but none was found.
        '';
      }
    ];

    environment.systemPackages = [inputs.deploy-rs.packages.${system}.default];

    sops.secrets.deploy_key = {
      owner = lib.head users;
      sopsFile = ../common/sops/deploy.yaml;
      path = "${config.hj.directory}/.ssh/deploy_key";
    };

    security.sudo.extraRules = lib.optional (deployers != {}) {
      users = lib.attrNames deployers;
      commands = [
        {
          command = activateRsCommand;
          options = ["NOPASSWD"];
        }
        {
          command = "/run/current-system/sw/bin/rm ${canaryRmGlob}";
          options = ["NOPASSWD"];
        }
      ];
    };
  };
}
