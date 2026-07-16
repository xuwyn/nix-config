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
      profileIcon = lib.mkOption {
        type = lib.types.attrsOf lib.types.path;
        default = {};
        description = "Per-user login icon";
      };
    };

    imports = [inputs.silentSDDM.nixosModules.default];

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

        (lib.mkIf (cfg.mode == "silent") {
          programs.silentSDDM = {
            enable = true;
            theme = "silvia";
            backgrounds = {
              cyTus = ../../../assets/sddm/cyTus.mp4;
              frame-1 = ../../../assets/sddm/frame-1.png;
            };
            profileIcons = lib.genAttrs users (name: cfg.profileIcon.${name} or ../../../assets/face.jpg);
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
