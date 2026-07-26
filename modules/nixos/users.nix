{
  modules.nixos.users = {
    pkgs,
    lib,
    config,
    ...
  }: let
    shellPackages = {
      zsh = pkgs.zsh;
      bash = pkgs.bash;
      fish = pkgs.fish;
    };

    shellsInUse = lib.unique (map (u: u.shell) (lib.attrValues config.nixos.users));
  in {
    options.nixos.users = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          shell = lib.mkOption {
            type = lib.types.enum ["zsh" "bash" "fish"];
            default = "zsh";
            description = "Default login shell for this user";
          };
          isAdmin = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether this user is granted wheel (sudo) access";
          };
          extraGroups = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "Additional groups beyond the common defaults";
          };
        };
      });
      default = {};
      description = "Per-user account configuration";
    };

    config = {
      programs.zsh.enable = lib.mkIf (builtins.elem "zsh" shellsInUse) true;
      programs.bash.enable = lib.mkIf (builtins.elem "bash" shellsInUse) true;
      programs.fish.enable = lib.mkIf (builtins.elem "fish" shellsInUse) true;

      users.mutableUsers = !(config ? sops);

      users.users = lib.mapAttrs (name: u:
        {
          isNormalUser = true;
          description = name;
          extraGroups =
            [
              "networkmanager"
              "video"
              "render"
              "input"
              "i2c"
            ]
            ++ lib.optional u.isAdmin "wheel"
            ++ u.extraGroups;
          shell = shellPackages.${u.shell};
        }
        // lib.optionalAttrs (config ? sops && config.sops.secrets ? "${name}_password") {
          hashedPasswordFile = config.sops.secrets."${name}_password".path;
        })
      config.nixos.users;
    };
  };
}
