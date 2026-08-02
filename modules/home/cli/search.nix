{
  modules.homeManager.cli = {
    lib,
    config,
    pkgs,
    ...
  }: let
    cfg = config.homeManager.cli.search;
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
