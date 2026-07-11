{
  flake.modules.homeManager.cli = {
    config,
    pkgs,
    lib,
    username,
    ...
  }: let
    cfg = config.homeManager.cli.git;
    isMatugenEnabled = config.programs.matugen.enable or false;
    accent =
      if isMatugenEnabled
      then "#" + config.programs.matugen.theme.colors.primary.default.color
      else "#89b4fa";
    foreground =
      if isMatugenEnabled
      then "#" + config.programs.matugen.theme.colors.surface_container_high.default.color
      else "#cdd6f4";
    muted =
      if isMatugenEnabled
      then "#" + config.programs.matugen.theme.colors.surface_variant.default.color
      else "#585b70";
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
      programs = {
        gh.enable = true; # enable github cli

        git = {
          enable = true;
          lfs.enable = true;
          signing = {
            key = config.sops.secrets.private_ssh_key.path;
            signByDefault = true;
          };
          settings = {
            core = {
              sshCommand = "ssh -i ${config.sops.secrets.private_ssh_key.path}";
            };
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
              selectedLineBgColor = [foreground];
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
