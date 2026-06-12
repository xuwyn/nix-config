{
  config,
  host,
  pkgs,
  ...
}: let
  inherit (import ../../../hosts/${host}/variables.nix) gitUsername gitEmail;
in {
  home.packages = with pkgs; [
    git-lfs
    git-filter-repo
  ];
  programs.git = {
    enable = true;
    signing = {
      key = "${config.home.homeDirectory}/.ssh/id_ed25519";
      signByDefault = true;
    };
    settings = {
      user = {
        name = "${gitUsername}";
        email = "${gitEmail}";
      };
      gpg.format = "ssh";
      commit.gpgsign = true;
      tag.gpgsign = true;

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
        gs = "stash";
        gp = "pull";
        lg = "log --graph --pretty=format:'%Cred%h%Creset - %C(yellow)%d%Creset %s %C(green)(%cr)%C(bold blue) <%an>%Creset' --abbrev-commit";
        st = "status";
      };
    };
  };
}
