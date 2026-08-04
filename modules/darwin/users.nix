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

      users.users =
        lib.mapAttrs (name: u: {
          home = "/Users/${name}";
          shell = shellPackages.${u.shell};
        })
        config.darwin.users;

      system.primaryUser = lib.head users;
    };
  };
}
