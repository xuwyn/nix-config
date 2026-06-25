{
  lib,
  config,
  username,
  host,
  inputs,
  ...
}:
with lib; let
  cfg = config.drivers.wsl;
in {
  options.drivers.wsl = {
    enable = mkEnableOption "Enable WSL";
  };
  imports = [inputs.nixos-wsl.nixosModules.default];
  config = mkIf cfg.enable {
    nixpkgs.hostPlatform = "x86_64-linux";

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
