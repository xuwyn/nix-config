{
  lib,
  config,
  username,
  host,
  ...
}:
with lib; let
  cfg = config.drivers.wsl;
in {
  options.drivers.wsl = {
    enable = mkEnableOption "Enable WSL";
  };

  config = mkIf cfg.enable {
    services.dbus.enable = true;
    wsl = {
      enable = true;
      defaultUser = username;
      useWindowsDriver = true;
      startMenuLaunchers = true;

      wslConf = {
        automount = {
          enabled = true;
          ldconfig = false;
          mountFsTab = false;
          root = "/mnt";
          options = "metadata,uid=1000,gid=100,umask=22,fmask=11";
        };
        boot.systemd = true;
        network = {
          hostname = host;
          generateHosts = true;
          generateResolvConf = true;
        };
        interop = {
          enabled = true;
          appendWindowsPath = true; # run .exe files from inside WSL
        };
      };
    };
  };
}
