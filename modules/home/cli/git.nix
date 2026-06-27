{
  flake.modules.homeManager.git = {
    config,
    pkgs,
    lib,
    username,
    ...
  }: let
    cfg = config.homeManager.git;
    accent = "#${config.lib.stylix.colors.base0D}";
    muted = "#${config.lib.stylix.colors.base03}";
  in {
    options.homeManager.git = {
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
    config = {
      home.packages = with pkgs; [
        git-lfs
        git-filter-repo
      ];
      programs = {
        gh.enable = true; # enable github cli

        git = {
          enable = true;
          lfs.enable = true;
          signing = {
            key = "${config.home.homeDirectory}/.ssh/id_ed25519";
            signByDefault = true;
          };
          settings = {
            user = {
              name = cfg.username;
              email = cfg.email;
            };
            gpg.format = "ssh";

            # FOSS-friendly settings
            push.default = "simple"; # Match modern push behavior
            credential.helper = "cache --timeout=7200";
            init.defaultBranch = "main"; # Set default new branches to 'main'
            log.decorate = "full"; # Show branch/tag info in git log
            log.date = "iso"; # ISO 8601 date format
            # Conflict resolution style for readable diffs
            merge.conflictStyle = "diff3";

            # Optional: FOSS-friendly Git aliases
            alias = {
              br = "branch --sort=-committerdate";
              co = "checkout";
              df = "diff";
              com = "commit -a";
              cl = "clone -c lfs.fetchexclude=*";
              lg = "log --graph --pretty=format:'%Cred%h%Creset - %C(yellow)%d%Creset %s %C(green)(%cr)%C(bold blue) <%an>%Creset' --abbrev-commit";
              st = "status";
            };
          };
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
              activeBorderColor = [accent "bold"];
              inactiveBorderColor = [muted];
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
