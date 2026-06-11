{
  pkgs,
  host,
  options,
  profile,
  ...
}: let
  inherit (import ../../hosts/${host}/variables.nix) hostId;
in {
  networking =
    {
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
    }
    // (
      if profile != "wsl"
      then {
        networkmanager.enable = true;
        timeServers = options.networking.timeServers.default ++ ["pool.ntp.org"];
      }
      else {}
    );

  environment.systemPackages = with pkgs; [networkmanagerapplet];
}
