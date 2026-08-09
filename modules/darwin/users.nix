{
  modules.darwin.users = {
    pkgs,
    lib,
    config,
    users,
    ...
  }: let
    shellPackages = {
      zsh = pkgs.zsh;
      bash = pkgs.bash;
      fish = pkgs.fish;
    };

    shellsInUse = lib.unique (lib.mapAttrsToList (_: u: u.shell) config.darwin.users);
  in {
    options.darwin.users = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          shell = lib.mkOption {
            type = lib.types.enum ["zsh" "bash" "fish"];
            default = "zsh";
            description = "Default login shell for this user";
          };
          sshKeys = lib.mkOption {
            type = lib.types.listOf lib.types.path;
            default = [];
            description = "Public key files for SSH login";
          };
        };
      });
      default = {};
      description = "Per-user account configuration (macOS account must already exist)";
    };

    config = {
      programs.zsh.enable = lib.mkIf (lib.elem "zsh" shellsInUse) true;
      programs.bash.enable = lib.mkIf (lib.elem "bash" shellsInUse) true;
      programs.fish.enable = lib.mkIf (lib.elem "fish" shellsInUse) true;

      environment.shells = map (s: shellPackages.${s}) shellsInUse;

      users.users = lib.mapAttrs (name: u:
        {
          home = "/Users/${name}";
          shell = shellPackages.${u.shell};
        }
        // lib.optionalAttrs (u.sshKeys != []) {
          openssh.authorizedKeys.keyFiles = u.sshKeys;
        })
      config.darwin.users;

      system.primaryUser = lib.head users;

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
        deploy ALL=(root) NOPASSWD: /nix/store/*/activate-rs, /bin/rm /tmp/deploy-rs-canary-*
      '';
    };
  };
}
