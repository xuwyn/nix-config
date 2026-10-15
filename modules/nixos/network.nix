{
  platforms = ["linux"];
  module = {
    config,
    lib,
    host,
    options,
    ...
  }: {
    options.custom.network.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Hostname, firewall, NetworkManager, avahi, and sshd";
    };

    config = lib.mkIf config.custom.network.enable {
      networking = {
        hostName = host;
        firewall = {
          enable = lib.mkDefault true;
          allowedTCPPorts = [22];
        };
        networkmanager.enable = lib.mkDefault true;
        timeServers = options.networking.timeServers.default ++ ["pool.ntp.org"];
      };

      services = {
        avahi = {
          enable = true;
          nssmdns4 = true;
          openFirewall = true; # port 5353
          publish = {
            enable = true;
            addresses = true;
          };
        };
        openssh = {
          enable = true;
          settings = {
            PermitRootLogin = "no";
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
          };
          ports = [22];
        };
      };

      programs.mtr.enable = true; # ping and traceroute
    };
  };
}
