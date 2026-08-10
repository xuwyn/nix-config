{
  modules = let
    activateRsCommand = "/nix/store/*/activate-rs";
    canaryRmGlob = "/tmp/deploy-rs-canary-*";

    mkDeployUserAssertion = platform: users: {
      assertion = users ? deploy;
      message = ''
        deploy-rs requires a user named "deploy" to be declared in
        modules.${platform}.users, but none was found.
      '';
    };
  in {
    nixos.deploy = {
      config,
      lib,
      ...
    }: {
      assertions = [(mkDeployUserAssertion "nixos" config.nixos.users)];

      security.sudo.extraRules =
        lib.optional
        (lib.any (u: u.isDeployer) (lib.attrValues config.nixos.users))
        {
          users = lib.attrNames (lib.filterAttrs (_: u: u.isDeployer) config.nixos.users);
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

    darwin.deploy = {
      config,
      lib,
      ...
    }: {
      assertions = [(mkDeployUserAssertion "darwin" config.darwin.users)];

      # Reactivate home manager at login
      # deploy-home.sh can't activate all services if user is logout
      launchd.user.agents.hm-activation = {
        serviceConfig = {
          ProgramArguments = [
            "/bin/sh"
            "-c"
            ''exec "$HOME/.local/state/nix/profiles/home-manager/activate" > /tmp/hm-activation.log 2>&1''
          ];
          WatchPaths = ["/nix/var/nix/daemon-socket/socket"];
        };
      };

      # give deploy limited sudo to commands that deploy-rs needs
      environment.etc."sudoers.d/deploy".text = ''
        deploy ALL=(root) NOPASSWD: ${activateRsCommand}, /bin/rm ${canaryRmGlob}
      '';
    };
  };
}
