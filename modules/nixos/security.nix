{
  modules.nixos.security = {...}: {
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    services = {
      openssh = {
        enable = true; # Enable SSH
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false; # use trusted ssh
          KbdInteractiveAuthentication = false; # No keyboard
        };
        ports = [22];
      };
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
}
