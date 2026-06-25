{
  flake.modules.nixos.xserver = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.nixos.xserver;
  in {
    options.nixos.xserver = {
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
      normalizeUSVariant = v:
        if v == "us-intl"
        then "intl"
        else v;

      layoutFromLayout =
        if builtins.elem cfg.keyboardLayout usVariants
        then "us"
        else cfg.keyboardLayout;

      variantFromLayout =
        if builtins.elem cfg.keyboardLayout usVariants
        then normalizeUSVariant cfg.keyboardLayout
        else "";

      layoutFromVariant =
        if builtins.elem cfg.keyboardVariant usVariants
        then "us"
        else layoutFromLayout;

      variantFinal =
        if builtins.elem cfg.keyboardVariant usVariants
        then normalizeUSVariant cfg.keyboardVariant
        else if variantFromLayout != ""
        then variantFromLayout
        else cfg.keyboardVariant;
    in {
      services.xserver = {
        enable = true;
        excludePackages = [pkgs.xterm];
        xkb = {
          layout = layoutFromVariant;
          variant = variantFinal;
        };
      };
    };
  };
}
