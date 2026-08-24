{
  modules.nixos.desktop = {
    config,
    lib,
    pkgs,
    users,
    inputs,
    ...
  }: let
    cfg = config.nixos.desktop.displayManager;
  in {
    options.nixos.desktop.displayManager = {
      enable = lib.mkEnableOption "Enable Display Manager";
      mode = lib.mkOption {
        type = lib.types.enum ["tui" "silent" "qylock"];
        default = "tui";
        description = "Choose Login Display Manager";
      };
      profileIcons = lib.mkOption {
        type = lib.types.attrsOf lib.types.path;
        default = {};
        description = "Per-user login icon";
      };
      # See: https://github.com/Darkkal44/qylock/tree/main/themes
      # My favourites: "pixel-skyscrapers" "pixel-night-city" "pixel-dusk-city" "pixel-coffee"
      qylock.theme = lib.mkOption {
        type = lib.types.str;
        default = "pixel-night-city";
        description = "Theme choice for Qylock";
      };
    };

    imports = with inputs; [
      silentSDDM.nixosModules.default
      qylock.nixosModules.default
    ];

    config = lib.mkIf cfg.enable (
      lib.mkMerge [
        (lib.mkIf (cfg.mode == "tui") {
          environment.systemPackages = with pkgs; [
            tuigreet
            cmatrix
          ];
          services.greetd.enable = lib.mkDefault false;
          services.displayManager.ly = {
            enable = true;
            settings = {
              animation = "matrix";
              bigclock = true;
              bg = "0x00000000";
              fg = "0x0000FFFF";
              border_fg = "0x00FF0000";
              error_fg = "0x00FF0000";
              clock_color = "#800080";
            };
          };
        })

        (lib.mkIf (cfg.mode == "silent" || cfg.mode == "qylock") {
          environment.systemPackages = [pkgs.bibata-cursors];
          services.displayManager.sddm = {
            enable = true;
            wayland.enable = lib.mkForce false; # nvidia shenanigan

            setupScript = ''
              ${pkgs.xrdb}/bin/xrdb -merge - <<EOF
              Xcursor.theme: Bibata-Modern-Ice
              Xcursor.size: 24
              EOF
            '';
          };
        })

        (lib.mkIf (cfg.mode == "qylock") {
          services.displayManager.sddm.extraPackages = with pkgs; [
            kdePackages.qt5compat
          ];

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
            inherit (cfg.qylock) theme;
            sddm.enable = true;
            quickshell.enable = false; # disable qylock-lock

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
        })

        (lib.mkIf (cfg.mode == "silent") {
          programs.silentSDDM = {
            enable = true;
            theme = "silvia";
            backgrounds = {
              cyTus = ../../../assets/sddm/cyTus.mp4;
              frame-1 = ../../../assets/sddm/frame-1.png;
            };
            profileIcons = lib.genAttrs users (name: cfg.profileIcons.${name} or ../../../assets/face.jpg);
            settings = {
              "General" = {
                scale = 1.0;
                enable-animations = true;
                animated-background-placeholder = "frame-1.png";
                background-fill-mode = "fill";
              };
              "LockScreen" = {
                background = "cyTus.mp4";
                saturation = 0;
              };
              "LoginScreen" = {
                background = "cyTus.mp4";
              };
            };
          };
        })
      ]
    );
  };
}
