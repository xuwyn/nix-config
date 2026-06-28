{
  flake.modules.homeManager.cli = {
    lib,
    config,
    ...
  }: let
    cfg = config.homeManager.cli;
    accent = "#" + config.lib.stylix.colors.base0D;
    foreground = "#" + config.lib.stylix.colors.base05;
    muted = "#" + config.lib.stylix.colors.base03;
  in {
    options.homeManager.cli = {
      zoxide.enable = lib.mkEnableOption "fast cd";
      fzf.enable = lib.mkEnableOption "fuzzy finder";
    };
    config = lib.mkMerge [
      (lib.mkIf cfg.fzf.enable {
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
      })
      (lib.mkIf cfg.zoxide.enable {
        programs.zoxide = {
          enable = true;
          enableZshIntegration = true;
          enableBashIntegration = true;
          options = [
            "--cmd cd"
          ];
        };
      })
    ];
  };
}
