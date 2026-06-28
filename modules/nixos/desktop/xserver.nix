{
  flake.modules.nixos.desktop = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.nixos.desktop.xserver;
  in {
    options.nixos.desktop.xserver = {
      enable = lib.mkEnableOption "Enable xserver for keyboard layout";
      keyboardLayout = lib.mkOption {
        type = lib.types.str;
        default = "us";
        description = "Keyboard layout (e.g., us, dvorak, fr)";
      };
      keyboardVariant = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Keyboard layout variant (e.g., intl, colemak)";
      };
    };

    config = let
      usVariants = ["dvorak" "colemak" "workman" "intl" "us-intl" "altgr-intl"];
      normalize = v:
        if v == "us-intl"
        then "intl"
        else v;

      isUSVariant = builtins.elem cfg.keyboardLayout usVariants || builtins.elem cfg.keyboardVariant usVariants;

      finalKbLayout =
        if isUSVariant
        then "us"
        else cfg.keyboardLayout;

      finalKbVariant =
        if builtins.elem cfg.keyboardVariant usVariants
        then normalize cfg.keyboardVariant
        else if builtins.elem cfg.keyboardLayout usVariants
        then normalize cfg.keyboardLayout
        else cfg.keyboardVariant;
    in
      lib.mkIf cfg.enable {
        services.xserver = {
          enable = true;
          excludePackages = [pkgs.xterm];
          xkb = {
            layout = finalKbLayout;
            variant = finalKbVariant;
          };
        };
      };
  };
}
