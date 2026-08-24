{
  modules.nixos.wsl = {
    lib,
    config,
    users,
    host,
    inputs,
    ...
  }: {
    imports = [inputs.nixos-wsl.nixosModules.default];
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
