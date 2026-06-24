{
  flake.modules.nixos.stylix = {
    pkgs,
    inputs,
    config,
    lib,
    ...
  }: let
    cfg = config.nixos.stylix;
  in {
    options.nixos.stylix = {
      image = lib.mkOption {
        type = lib.types.path;
        description = "Set Stylix Theme via Image Path (cannot be null)";
      };
    };
    imports = [inputs.stylix.nixosModules.stylix];
    config = {
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
            package = pkgs.montserrat;
            name = "Montserrat";
          };
          serif = {
            package = pkgs.montserrat;
            name = "Montserrat";
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
