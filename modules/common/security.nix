{
  modules = let
    gnupgAgentConfig = {
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };
  in {
    nixos.security = {
      imports = [gnupgAgentConfig];
      services.openssh = {
        enable = true; # Enable SSH
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
        ports = [22];
      };
      security = {
        rtkit.enable = true;
        polkit = {
          enable = true;
          extraConfig = ''
            polkit.addRule(function(action, subject) {
              if ( subject.isInGroup("users") && (
               action.id == "org.freedesktop.login1.reboot" ||
               action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
               action.id == "org.freedesktop.login1.power-off" ||
               action.id == "org.freedesktop.login1.power-off-multiple-sessions"
              ))
              { return polkit.Result.YES; }
            })
          '';
        };
      };
    };

    darwin.security = {
      imports = [gnupgAgentConfig];
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
