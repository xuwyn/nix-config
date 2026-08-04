{
  modules.darwin.security = {...}: {
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    services.openssh.enable = true; # Remote Login
  };
}
