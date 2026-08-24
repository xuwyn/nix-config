{
  modules.darwin.network = {host, ...}: {
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
}
