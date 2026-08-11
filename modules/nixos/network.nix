{
  modules.nixos.network = {
    pkgs,
    lib,
    host,
    options,
    ...
  }: {
    environment.systemPackages = with pkgs; [networkmanagerapplet];
    networking = {
      hostName = host;
      firewall = {
        enable = lib.mkDefault true;
        allowedTCPPorts = [
          22
          80
          443
        ];
      };
      networkmanager.enable = true;
      timeServers = options.networking.timeServers.default ++ ["pool.ntp.org"];
    };
  };
}
