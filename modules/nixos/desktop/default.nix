{
  tags = ["desktop"];
  platforms = ["linux"];
  module = {
    pkgs,
    config,
    lib,
    inputs,
    self,
    system,
    ...
  }: let
    wm = self.wrapperModules.${system};
    umbriel = wm.umbriel {inherit (config.custom) desktop;};
    noctalia = wm.noctalia {
      inherit (config.custom) desktop;
      extraSettings = let
        writeUmbrielConfig = ''
          mkdir -p ~/.config/umbriel && cat > ~/.config/umbriel/config.toml <<'EOF'
          [include.optional]
          files = ["noctalia.toml"]
          EOF
        '';
      in {
        # so umbriel template's apply.sh can drop the annoying warning (2026-10-25)
        hooks = {
          colors_changed = writeUmbrielConfig;
          theme_mode_changed = writeUmbrielConfig;
          wallpaper_changed = writeUmbrielConfig;
        };
      };
    };
  in {
    imports = [inputs.umbriel.nixosModules.default];

    programs.umbriel = {
      enable = lib.mkDefault true;
      package = umbriel;
    };

    environment.systemPackages = with pkgs; [
      umbriel
      (wm.mpv {})
      (wm.swayimg {})
      playerctl
      noctalia
      slurp # gsr region capture
      evtest # bongocat
      tesseract # ocr
    ];
  };
}
