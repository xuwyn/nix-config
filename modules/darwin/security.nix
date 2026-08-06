{
  modules.darwin.security = {...}: {
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
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
