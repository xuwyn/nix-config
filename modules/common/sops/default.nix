{
  inputs,
  pkgs,
  host,
  lib,
  system,
  ...
}: let
  class =
    if lib.hasSuffix "-darwin" system
    then "darwinModules"
    else "nixosModules";
in {
  imports = [inputs.sops-nix.${class}.sops];

  environment = {
    systemPackages = with pkgs; [ssh-to-age age sops];
    variables.SOPS_AGE_KEY_CMD = "ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key";
  };

  sops = {
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    defaultSopsFile = ./${host}.yaml;
    defaultSopsFormat = "yaml";
  };
}
