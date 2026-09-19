{
  modules.homeManager.cli = {
    config,
    pkgs,
    lib,
    username,
    ...
  }: let
    cfg = config.homeManager.cli.git;
  in {
    options.homeManager.cli.git = {
      enable = lib.mkEnableOption "Enable Git and lazygit";
      username = lib.mkOption {
        type = lib.types.str;
        default = username;
        description = "Set Git username";
      };
      email = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Set Git email";
      };
    };
    config = lib.mkIf cfg.enable {
      home.packages = with pkgs; [
        git-lfs
        git-filter-repo
      ];
      home.shellAliases = {
        gr = "git restore";
        gl = "git log --graph --pretty=format:'%Cred%h%Creset - %C(yellow)%d%Creset %s %C(green)(%cr)%C(bold blue) <%an>%Creset' --abbrev-commit";
        gs = "git status";
        gd = "git diff";
        ga = "git add .";
        gb = "git branch -a";
      };
      programs.gh.enable = true; # enable github cli
      programs.git = {
        enable = true;
        lfs.enable = true;
        signing = {
          key = config.sops.secrets.private_ssh_key.path;
          signByDefault = true;
        };
        settings = {
          core = {
            sshCommand = "ssh -i ${config.sops.secrets.private_ssh_key.path}";
            editor = "nvim";
          };
          user = {
            name = cfg.username;
            email = cfg.email;
          };
          gpg.format = "ssh";
          push.default = "simple"; # Match modern push behavior
          credential.helper = "cache --timeout=7200";
          init.defaultBranch = "main"; # Set default new branches to 'main'
          log.decorate = "full"; # Show branch/tag info in git log
          log.date = "iso"; # ISO 8601 date format
          merge.conflictStyle = "diff3"; # Conflict resolution style for readable diffs
        };
      };
      programs.lazygit = {
        enable = true;
        settings = lib.mkForce {
          disableStartupPopups = true;
          notARepository = "skip";
          promptToReturnFromSubprocess = false;
          update.method = "never";
          git = {
            commit.signOff = true;
            parseEmoji = true;
          };
          gui = {
            theme = {
              activeBorderColor = ["#89b4fa" "bold"];
              inactiveBorderColor = ["#585b70"];
              searchingActiveBorderColor = ["#94e2d5" "bold"];
              optionsTextColor = ["#89b4fa"];
              selectedLineBgColor = ["#45475a"];
              inactiveViewSelectedLineBgColor = ["bold"];
              cherryPickedCommitFgColor = ["#1e1e2e"];
              cherryPickedCommitBgColor = ["#94e2d5"];
              markedBaseCommitFgColor = ["#1e1e2e"];
              markedBaseCommitBgColor = ["#f9e2af"];
              unstagedChangesColor = ["#f38ba8"];
              defaultFgColor = ["#cdd6f4"];
            };
            showListFooter = false;
            showRandomTip = false;
            showCommandLog = false;
            showBottomLine = false;
            nerdFontsVersion = "3";
          };
        };
      };
    };
  };
}
