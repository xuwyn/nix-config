{
  modules.darwin.network = {host, ...}: {
    networking = {
      hostName = host;
      computerName = host;
      applicationFirewall.enable = true;
    };
  };
}
