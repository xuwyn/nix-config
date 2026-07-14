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
    };

    config = {
      users.mutableUsers = false;
      users.users = lib.genAttrs users (name:
        {
          isNormalUser = true;
          description = name;

          extraGroups = [
            "wheel" # sudo access
            "networkmanager" # Network control
            "video" # Core graphics
            "render" # Core graphics acceleration
            "input" # Basic input
            "i2c" # brightnessctl ddcutil openrgb
          ];

          # Safe systemd-compliant way to assign the default shell
          shell = pkgs.${cfg.shell.${name} or "zsh"};
          ignoreShellProgramCheck = true;
        }
        // lib.optionalAttrs (config.sops.secrets ? "${name}_password") {
          hashedPasswordFile = config.sops.secrets."${name}_password".path;
        });
    };
  };
}
