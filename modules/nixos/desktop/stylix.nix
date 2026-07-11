{
  modules.nixos.desktop = {
    pkgs,
    inputs,
    config,
    lib,
    ...
  }: let
    cfg = config.nixos.desktop.stylix;
  in {
    options.nixos.desktop.stylix = {
      enable = lib.mkEnableOption "Enable stylix system wide (icons, plymouth, etc.)";
      image = lib.mkOption {
        type = lib.types.path;
        description = "Set Stylix Theme via Image Path (cannot be null)";
      };
    };
    imports = [inputs.stylix.nixosModules.stylix];
    config = lib.mkIf cfg.enable {
      stylix = {
        enable = true;
        image = cfg.image;
        targets = {
          kmscon.enable = false; # tty
        };
        polarity = "dark";
        cursor = {
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Ice";
          size = 24;
        };
        fonts = {
          monospace = {
            package = pkgs.nerd-fonts.jetbrains-mono;
            name = "JetBrains Mono";
          };
          sansSerif = {
            package = pkgs.nerd-fonts.noto;
            name = "Noto Sans";
          };
          serif = {
            package = pkgs.nerd-fonts.noto;
            name = "Noto Serif";
          };
          sizes = {
            applications = 12;
            terminal = 15;
            desktop = 11;
            popups = 12;
          };
        };
      };
    };
  };
}
