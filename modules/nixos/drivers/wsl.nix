{
  modules.nixos.drivers = {
    lib,
    config,
    users,
    host,
    inputs,
    ...
  }:
    with lib; let
      cfg = config.nixos.drivers.wsl;
    in {
      options.nixos.drivers.wsl = {
        enable = mkEnableOption "Enable WSL";
      };
      imports = [inputs.nixos-wsl.nixosModules.default];
      config = mkIf cfg.enable {
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
    };
}
