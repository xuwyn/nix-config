{
  modules.nixos.users = {
    pkgs,
    users,
    lib,
    config,
    ...
  }: let
    cfg = config.nixos.users;
  in {
    options.nixos.users = {
      shell = lib.mkOption {
        type = lib.types.attrsOf (lib.types.enum ["zsh" "bash" "fish"]);
        default = {};
        description = "Per-user default shell";
      };
      admins = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "List of users granted wheel (sudo) access";
      };
    };

    config = {
      users.mutableUsers = !(config ? sops);
      users.users = lib.genAttrs users (name:
        {
          isNormalUser = true;
          description = name;

          extraGroups =
            [
              "networkmanager" # Network control
              "video" # Core graphics
              "render" # Core graphics acceleration
              "input" # Basic input
              "i2c" # brightnessctl ddcutil openrgb
            ]
            ++ lib.optional (builtins.elem name cfg.admins) "wheel";

          # Safe systemd-compliant way to assign the default shell
          shell = pkgs.${cfg.shell.${name} or "zsh"};
          ignoreShellProgramCheck = true;
        }
        // lib.optionalAttrs (config ? sops && config.sops.secrets ? "${name}_password") {
          hashedPasswordFile = config.sops.secrets."${name}_password".path;
        });
    };
  };
}
