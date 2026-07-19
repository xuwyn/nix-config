{
  modules.homeManager.cli = {
    lib,
    config,
    pkgs,
    ...
  }: let
    cfg = config.homeManager.cli.search;
    matugenEnabled = config.programs.matugen.enable or false;
    accent =
      if matugenEnabled
      then "#" + config.programs.matugen.theme.colors.primary.default.color
      else "#89b4fa";
    foreground =
      if matugenEnabled
      then "#" + config.programs.matugen.theme.colors.on_surface.default.color
      else "#cdd6f4";
    muted =
      if matugenEnabled
      then "#" + config.programs.matugen.theme.colors.surface_variant.default.color
      else "#585b70";
  in {
    options.homeManager.cli.search = {
      enable = lib.mkEnableOption "Enable search utils for cli";
    };
    config = lib.mkIf cfg.enable {
      # regrex search
      programs.ripgrep = {
        enable = true;
      };

      # find replacement
      programs.fd = {
        enable = true;
        hidden = true;
        ignores = []; # list of ignored files
      };

      # fuzzy search
      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
        colors = lib.mkForce {
          "fg+" = accent;
          "bg+" = "-1";
          "fg" = foreground;
          "bg" = "-1";
          "prompt" = muted;
          "pointer" = accent;
        };
        defaultOptions = [
          "--margin=1"
          "--layout=reverse"
          "--border=none"
          "--info='hidden'"
          "--header=''"
          "--prompt='/ '"
          "-i"
          "--no-bold"
          "--bind='enter:execute(nvim {})'"
          "--preview='bat --style=numbers --color=always --line-range :500 {}'"
          "--preview-window=right:60%:wrap"
        ];
      };

      # cd history
      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
        options = [
          "--cmd cd"
        ];
      };
    };
  };
}
