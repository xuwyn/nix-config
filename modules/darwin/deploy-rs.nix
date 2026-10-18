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
    options.custom.deploy.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "deploy-rs target setup: deploy key, sudoers rule, and activation agent";
    };

    config = lib.mkIf config.custom.deploy.enable {
      assertions = [
        {
          assertion = config.custom.users ? deploy;
          message = ''
            deploy-rs requires a user named "deploy" to be declared in
            this host's users, but none was found.
          '';
        }
      ];

      sops.secrets.deploy_key = {
        owner = lib.head users;
        sopsFile = ../common/sops/deploy.yaml;
        path = "${config.hj.directory}/.ssh/deploy_key";
      };

      launchd.user.agents.hm-activation.serviceConfig = {
        ProgramArguments = [
          "/bin/sh"
          "-c"
          ''exec "$HOME/.local/state/nix/profiles/home-manager/activate" > /tmp/hm-activation.log 2>&1''
        ];
        WatchPaths = ["/nix/var/nix/daemon-socket/socket"];
      };

      environment.etc."sudoers.d/deploy".text = ''
        deploy ALL=(root) NOPASSWD: ${activateRsCommand}, /bin/rm ${canaryRmGlob}
      '';
    };
  };
}
