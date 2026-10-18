{
  platforms = ["darwin"];
  module = {
    config,
    lib,
    users,
    system,
    ...
  }: let
    activateRsCommand = "/nix/store/*/activate-rs";
    canaryRmGlob = "/tmp/deploy-rs-canary-*";
  in {
    options.custom.deploy = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "deploy-rs support: deploy user assertion and sudoers rule";
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
            assertion = config.custom.users ? deploy;
            message = ''
              deploy-rs requires a user named "deploy" to be declared in
              this host's users, but none was found.
            '';
          }
        ];

        environment.etc."sudoers.d/deploy".text = ''
          deploy ALL=(root) NOPASSWD: ${activateRsCommand}, /bin/rm ${canaryRmGlob}
        '';
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
