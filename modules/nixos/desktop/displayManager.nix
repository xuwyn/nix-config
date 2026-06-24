{
  flake.modules.nixos.displayManager = {
    config,
    lib,
    pkgs,
    username,
    inputs,
    ...
  }: let
    cfg = config.nixos.displayManager;
  in {
    options.nixos.displayManager = {
      mode = lib.mkOption {
        type = lib.types.enum ["tui" "silent" "qylock"];
        default = "tui";
        description = "Choose Login Display Manager";
      };
    };

    imports = [inputs.silentSDDM.nixosModules.default];

    config = lib.mkMerge [
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
            # --- Color Settings (0xAARRGGBB) ---
            # Background color of dialog box (Black)
            bg = "0x00000000";
            # Foreground text color (Cyan: #00FFFF)
            fg = "0x0000FFFF";
            # Border color (Red: #FF0000)
            border_fg = "0x00FF0000";
            # Error message color (Red)
            error_fg = "0x00FF0000";
            # Clock color (Purple: #800080)
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

      (lib.mkIf (cfg.mode == "silent") {
        programs.silentSDDM = {
          enable = true;
          theme = "silvia";
          backgrounds = {
            cyTus = ../../../wallpapers/cyTus.mp4;
            frame-1 = ../../../wallpapers/frame-1.png;
          };
          profileIcons = {
            ${username} = ../../_home/hyprland/face.jpg;
          };
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
    ];
  };
}
