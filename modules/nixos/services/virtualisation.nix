{
  flake.modules.nixos.virtualisation = {
    pkgs,
    username,
    ...
  }: {
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
}
