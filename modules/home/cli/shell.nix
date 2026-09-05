{
  modules.homeManager.cli = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.homeManager.cli;
  in {
    options.homeManager.cli = {
      extraShellAliases = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
        description = "Additional shell aliases";
      };
      bash.enable = lib.mkEnableOption "Enable bash";
      zsh.enable = lib.mkEnableOption "Enable zsh";
    };

    config = lib.mkMerge [
      {
        home.shellAliases =
          {
            sv = "sudo -E nvim";
            v = "nvim";
            c = "clear";
            ncg = "nix-collect-garbage --delete-old && nix-collect-garbage -d && nix-store --gc && nix-store --optimise";
            ".." = "cd ..";
          }
          // cfg.extraShellAliases;
      }
      (lib.mkIf cfg.bash.enable {
        home.packages = [pkgs.microfetch];
        programs.bash = {
          enable = true;
          enableCompletion = true;
          initExtra = ''
            microfetch
          '';
        };
      })
      (lib.mkIf cfg.zsh.enable {
        programs.zsh = {
          enable = true;
          dotDir = config.home.homeDirectory;
          autosuggestion.enable = true;
          syntaxHighlighting = {
            enable = true;
            highlighters = ["main" "brackets" "pattern" "regexp" "root" "line"];
          };
          historySubstringSearch.enable = true;
          history = {
            ignoreDups = true;
            save = 10000;
            size = 10000;
          };
          oh-my-zsh = {
            enable = true;
            theme = "";
          };
          plugins = [];
          initContent = ''
            bindkey "\eh" backward-word
            bindkey "\ej" down-line-or-history
            bindkey "\ek" up-line-or-history
            bindkey "\el" forward-word

            fastfetch
          '';
        };
      })
    ];
  };
}
