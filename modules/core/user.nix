{
  pkgs,
  username,
  host,
  ...
}: let
  vars = import ../../hosts/${host}/variables.nix;
  inherit (vars) gitUsername;
  shell = vars.shell or "bash";
  virtEnable = vars.virtEnable or false;
  printEnable = vars.printEnable or false;
in {
  users.mutableUsers = true;
  users.users.${username} = {
    isNormalUser = true;
    description = "${gitUsername}";
    extraGroups =
      [
        "wheel" # sudo access
        "networkmanager" # Network control
        "video" # Core graphics
        "render" # Core graphics acceleration
        "input" # Basic inpu
        "i2c" # (brightnessctl ddcutil openrgb)
      ]
      ++ (
        if virtEnable
        then [
          "docker"
          "libvirtd"
          "vboxusers"
          "adbusers"
        ]
        else []
      )
      ++ (
        if printEnable
        then ["lp" "scanner"]
        else []
      )
      # Add any extra groups defined per-host
      ++ (vars.extraUserGroups or []);

    shell = pkgs.${shell};
    ignoreShellProgramCheck = true;
  };
  nix.settings.allowed-users = ["${username}"];
}
