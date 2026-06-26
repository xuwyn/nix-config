{
  flake.modules.nixos.steam = {
    pkgs,
    inputs,
    username,
    ...
  }: {
    imports = [inputs.chaotic.nixosModules.default];

    users.users.${username} = {
      extraGroups = ["gamemode"];
    };

    programs = {
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = false;
        gamescopeSession.enable = true;
        extraCompatPackages = [
          pkgs.proton-ge-bin
          pkgs.proton-cachyos
        ];
      };
      gamemode = {
        enable = true;
      };
      gamescope = {
        enable = true;
        capSysNice = true;
        args = [
          "--rt"
          "--expose-wayland"
        ];
      };
    };

    services = {
      scx = {
        enable = true;
        scheduler = "scx_lavd";
      };
      ananicy = {
        enable = true;
        package = pkgs.ananicy-cpp;
        rulesProvider = pkgs.ananicy-rules-cachyos;
      };
    };
  };
}
