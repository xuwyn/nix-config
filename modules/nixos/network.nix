{
  flake.modules.nixos.network = {
    pkgs,
    profile,
    lib,
    config,
    host,
    options,
    ...
  }: let
    cfg = config.nixos.network;
  in {
    options.nixos.network = {
      hostId = lib.mkOption {
        type = lib.types.str;
        description = "Set Network Host Id";
      };
    };
    config = {
      environment.systemPackages = with pkgs; [networkmanagerapplet];
      networking = {
        hostName = host;
        hostId = cfg.hostId;
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
  };
}
