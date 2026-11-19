{
  platform = "darwin";
  module = {
    config,
    users,
    lib,
    ...
  }: let
    installLabel = "system/org.nixos.sops-install-secrets";
    wipeLabel = "system/org.nixos.sops-wipe";
    kick = label: "/bin/launchctl kickstart -k ${label}";
  in {
    # only the session agent installs, never at boot
    launchd.daemons.sops-install-secrets.serviceConfig.RunAtLoad = lib.mkForce false;

    # wipe secrets
    launchd.daemons.sops-wipe = {
      command = "rm -rf /run/secrets /run/secrets-for-users /run/secrets.d";
      serviceConfig.RunAtLoad = false;
    };

    # install at login if key present, wipe at logout
    launchd.user.agents.sops-session = {
      serviceConfig = {
        ProgramArguments = [
          "/bin/sh"
          "-c"
          ''
            trap 'sudo -n ${kick wipeLabel}' TERM EXIT
            if /usr/sbin/ioreg -r -c IOUSBHostDevice | /usr/bin/grep -q '"idVendor" = 4176'; then
              sudo -n ${kick installLabel}
            else
              sudo -n ${kick wipeLabel}
            fi
            tail -f /dev/null &
            wait $!
          ''
        ];
        KeepAlive = true;
        RunAtLoad = true;
      };
    };

    security.sudo.extraConfig = ''
      ${lib.head users} ALL=(root) NOPASSWD: ${kick installLabel}, ${kick wipeLabel}
    '';
  };
}
