{
  tags = ["wsl"];
  platforms = ["linux"];
  module = {
    lib,
    users,
    host,
    inputs,
    ...
  }: {
    imports = [inputs.nixos-wsl.nixosModules.default];

    # override hardware/service defaults
    networking.networkmanager.enable = false;
    hardware = {
      enableRedistributableFirmware = false;
      i2c.enable = false;
    };
    services.fstrim.enable = false;

    wsl = {
      enable = true;
      defaultUser = lib.head users;
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
