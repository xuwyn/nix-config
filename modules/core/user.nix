{
  pkgs,
  username,
  host,
  lib,
  ...
}: let
  vars = import ../../hosts/${host}/variables.nix;
  inherit (vars) gitUsername;
  shell = vars.shell or "zsh";
in {
  users.mutableUsers = true;
  users.users.${username} = {
    isNormalUser = true;
    description = gitUsername;

    extraGroups =
      [
        "wheel" # sudo access
        "networkmanager" # Network control
        "video" # Core graphics
        "render" # Core graphics acceleration
        "input" # Basic input
        "i2c" # brightnessctl ddcutil openrgb
      ]
      ++ lib.optionals (vars.virtEnable or false) ["docker" "libvirtd" "vboxusers" "adbusers"]
      ++ lib.optionals (vars.printEnable or false) ["lp" "scanner"]
      ++ lib.optionals (vars.steamEnable or false) ["gamemode"]
      ++ (vars.extraUserGroups or []);

    # Safe systemd-compliant way to assign the default shell
    shell = pkgs.${shell};
    ignoreShellProgramCheck = true;
  };
}
