{
  modules.nixos.network = {
    pkgs,
    config,
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
      networkmanager.enable =
        if (config ? nixos.drivers.wsl.enable)
        then !config.nixos.drivers.wsl.enable
        else true;
      timeServers =
        if (config ? nixos.drivers.wsl.enable) && config.nixos.drivers.wsl.enable
        then options.networking.timeServers.default
        else options.networking.timeServers.default ++ ["pool.ntp.org"];
    };
  };
}
