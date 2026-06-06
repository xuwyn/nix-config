{
  pkgs,
  inputs,
  username,
  host,
  profile,
  ...
}: let
  inherit (import ../../hosts/${host}/variables.nix) gitUsername;
in {
  users.mutableUsers = true;
  users.users.${username} = {
    isNormalUser = true;
    description = "${gitUsername}";
    extraGroups = [
      "adbusers"
      "docker" #access to docker as non-root
      "libvirtd" #Virt manager/QEMU access
      "lp"
      "networkmanager"
      "scanner"
      "wheel" #sudo access
      "vboxusers" #Virtual Box
      "i2c" #ddcutil (brightness) & openrgb
      "input"
    ];
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
  };
  nix.settings.allowed-users = ["${username}"];
}
