{
  pkgs,
  host,
  options,
  profile,
  lib,
  ...
}: let
  inherit (import ../../hosts/${host}/variables.nix) hostId;
in {
  networking = {
    hostName = "${host}";
    hostId = hostId;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        80
        443
        59010
        59011
        8080
      ];
      allowedUDPPorts = [
        59010
        59011
      ];
    };
    networkmanager.enable = lib.mkIf (profile != "wsl") true;
    timeServers = lib.mkIf (profile != "wsl") (options.networking.timeServers.default ++ ["pool.ntp.org"]);
  };

  environment.systemPackages = with pkgs; [networkmanagerapplet];
}
