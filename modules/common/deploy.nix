{
  modules = let
    activateRsCommand = "/nix/store/*/activate-rs";
    canaryRmGlob = "/tmp/deploy-rs-canary-*";

    mkDeployUserAssertion = users: {
      assertion = users ? deploy;
      message = ''
        deploy-rs requires a user named "deploy" to be declared in
        this host's users, but none was found.
      '';
    };

    mkDeployCommonConfig = {
      config,
      lib,
      inputs,
      pkgs,
      users,
      ...
    }: {
      environment.systemPackages = [inputs.deploy-rs.packages.${pkgs.stdenv.hostPlatform.system}.default];
      sops.secrets.deploy_key = {
        owner = lib.head users;
        sopsFile = ./sops/deploy.yaml;
        path = "${config.hj.directory}/.ssh/deploy_key";
      };
    };

    mkSystemDeployModule = extra: {
      config,
      lib,
      inputs,
      pkgs,
      users,
      ...
    } @ args:
      lib.mkMerge [
        (mkDeployCommonConfig args)
        (extra args)
      ];
  in {
    nixos.deploy = mkSystemDeployModule ({
      config,
      lib,
      users,
      ...
    }: {
      assertions = [(mkDeployUserAssertion config.nixos.users)];
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
    });

    darwin.deploy = mkSystemDeployModule ({config, ...}: {
      assertions = [(mkDeployUserAssertion config.darwin.users)];
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
      environment.etc."sudoers.d/deploy".text = ''
        deploy ALL=(root) NOPASSWD: ${activateRsCommand}, /bin/rm ${canaryRmGlob}
      '';
    });
  };
}
