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
      bash = {
        enable = lib.mkEnableOption "Enable bash";
        extraShellAliases = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = {};
          description = "Additional shell aliases";
        };
      };
      zsh = {
        enable = lib.mkEnableOption "Enable zsh";
        extraShellAliases = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = {};
          description = "Additional shell aliases";
        };
      };
    };

    config = lib.mkMerge [
      (lib.mkIf cfg.bash.enable {
        home.packages = [pkgs.microfetch];
        programs.bash = {
          enable = true;
          enableCompletion = true;
          initExtra = ''
            microfetch
          '';

          shellAliases =
            {
              sv = "sudo -E nvim";
              v = "nvim";
              c = "clear";
              ncg = "nix-collect-garbage --delete-old && nix-collect-garbage -d && nix-store --gc && nix-store --optimise";
              gl = "git log";
              gs = "git status";
              gd = "git diff";
              ga = "git add .";
              gb = "git branch -a";
              ".." = "cd ..";
            }
            // cfg.bash.extraShellAliases;
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

          shellAliases =
            {
              sv = "sudo -E nvim";
              v = "nvim";
              c = "clear";
              ncg = "nix-collect-garbage --delete-old && nix-collect-garbage -d && nix-store --gc && nix-store --optimise";
              cat = "bat";
              man = "batman";
              gl = "git log";
              gs = "git status";
              gd = "git diff";
              ga = "git add .";
              gb = "git branch -a";
              ".." = "cd ..";
            }
            // cfg.zsh.extraShellAliases;
        };
      })
    ];
  };
}
