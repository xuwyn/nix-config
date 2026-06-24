{
  flake.modules.nixos.user = {
    pkgs,
    username,
    lib,
    config,
    ...
  }: let
    cfg = config.nixos.user;
  in {
    options.nixos.user = {
      shell = lib.mkOption {
        type = lib.types.enum ["zsh" "bash" "fish"];
        default = "zsh";
        description = "Set user default shell";
      };
    };

    config = {
      users.mutableUsers = true;
      users.users.${username} = {
        isNormalUser = true;
        description = username;

        extraGroups = [
          "wheel" # sudo access
          "networkmanager" # Network control
          "video" # Core graphics
          "render" # Core graphics acceleration
          "input" # Basic input
          "i2c" # brightnessctl ddcutil openrgb
        ];

        # Safe systemd-compliant way to assign the default shell
        shell = pkgs.${cfg.shell};
        ignoreShellProgramCheck = true;
      };
    };
  };
}
