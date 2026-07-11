{
  modules.nixos.services = {
    pkgs,
    username,
    config,
    lib,
    ...
  }: let
    cfg = config.nixos.services.virtualisation;
  in {
    options.nixos.services.virtualisation = {
      enable = lib.mkEnableOption "Enable virtualisation (docker, virtualbox, etc.)";
    };
    config = lib.mkIf cfg.enable {
      users.users.${username} = {
        extraGroups = ["docker" "libvirtd" "vboxusers" "adbusers"];
      };

      # Only enable either docker or podman -- Not both
      virtualisation = {
        docker = {
          enable = true;
        };

        podman.enable = false;

        libvirtd = {
          enable = true;
        };

        virtualbox.host = {
          enable = false;
          enableExtensionPack = true;
        };
      };

      programs = {
        virt-manager.enable = false;
      };

      environment.systemPackages = with pkgs; [
        virt-viewer # View Virtual Machines
        lazydocker
        docker-client
      ];
    };
  };
}
