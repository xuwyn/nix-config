{
  modules.nixos.apps = {
    pkgs,
    inputs,
    username,
    config,
    lib,
    ...
  }: let
    cfg = config.nixos.apps.steam;
  in {
    options.nixos.apps.steam.enable = lib.mkEnableOption "Enable steam";
    config = lib.mkIf cfg.enable {
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
  };
}
