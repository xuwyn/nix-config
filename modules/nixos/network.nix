{
  modules.nixos.network = {
    pkgs,
    profile,
    lib,
    host,
    options,
    ...
  }: {
    environment.systemPackages = with pkgs; [networkmanagerapplet];
    networking = {
      hostName = host;
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
  };
}
