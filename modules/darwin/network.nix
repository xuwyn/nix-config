{
  platforms = ["darwin"];
  module = {
    config,
    lib,
    host,
    ...
  }: {
    options.custom.network.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Hostname, application firewall, and sshd";
    };

    config = lib.mkIf config.custom.network.enable {
      networking = {
        hostName = host;
        computerName = host;
        applicationFirewall.enable = true;
      };

      services.openssh = {
        enable = true;
        # same settings as nixos' openssh
        extraConfig = ''
          PermitRootLogin no
          PasswordAuthentication no
          KbdInteractiveAuthentication no
        '';
      };
    };
  };
}
