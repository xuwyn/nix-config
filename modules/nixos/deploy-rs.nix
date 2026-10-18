{
  platforms = ["linux"];
  module = {
    config,
    lib,
    users,
    system,
    ...
  }: let
    activateRsCommand = "/nix/store/*/activate-rs";
    canaryRmGlob = "/tmp/deploy-rs-canary-*";

    systemUsers = config.custom.users;
    deployers = lib.filterAttrs (_: u: u.isDeployer) systemUsers;
  in {
    options.custom.deploy = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "deploy-rs support: deploy user assertion and sudoers rules";
      };

      controller.enable = lib.mkEnableOption ''
        controller role: this host can deploy to other hosts
      '';
    };

    config = lib.mkIf config.custom.deploy.enable (lib.mkMerge [
      # Target side: every host that can be deployed to
      {
        assertions = [
          {
            assertion = systemUsers ? deploy;
            message = ''
              deploy-rs requires a user named "deploy" to be declared in
              this host's users, but none was found.
            '';
          }
        ];

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
      }

      # Controller side: only hosts that deploy to others need the private key
      (lib.mkIf config.custom.deploy.controller.enable {
        sops.secrets.deploy_key = {
          owner = lib.head users;
          sopsFile = ../common/sops/deploy.yaml;
          path = "${config.hj.directory}/.ssh/deploy_key";
        };
      })
    ]);
  };
}
