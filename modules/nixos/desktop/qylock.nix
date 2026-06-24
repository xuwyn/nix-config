{
  flake.modules.nixos.qylock = {
    inputs,
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.nixos.qylock;
    qylockSDDMEnable = config.nixos.displayManager.mode == "qylock";
  in {
    options.nixos.qylock = {
      # See: https://github.com/Darkkal44/qylock/tree/main/themes
      # My favourites: "pixel-skyscrapers" "pixel-night-city" "pixel-dusk-city" "pixel-coffee"
      theme = lib.mkOption {
        type = lib.types.str;
        default = "pixel-night-city";
        description = "Theme choice for Qylock";
      };
    };

    imports = [inputs.qylock.nixosModules.default];

    config = {
      environment.systemPackages = with pkgs; [
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-ugly
      ];

      # nvidia shenanigan
      environment.sessionVariables = {
        QT_DISABLE_HW_TEXTURES_CONVERSION = "1";
      };

      programs.qylock = {
        enable = true;
        theme = cfg.theme;
        sddm.enable = qylockSDDMEnable;
        quickshell.enable = true;

        # Optional per-theme tweaks (replaces the interactive prompts):
        themeOptions = {
          terraria.backgroundMode = "time"; # time | random | static
          Genshin.backgroundMode = "time";
          clockwork.orbital = {
            themeMode = "dark";
            enableWindup = true;
          };
          osu.gameMode = "menu"; # menu | game
        };
      };
    };
  };
}
