{
  modules.homeManager.cli = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.homeManager.cli.styling;
  in {
    options.homeManager.cli.styling = {
      enable = lib.mkEnableOption "Enable styling utils for cli";
    };

    config = lib.mkIf cfg.enable {
      # shell prompt styling
      programs.starship = {
        enable = true;
        package = pkgs.starship;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
        presets = ["nerd-font-symbols" "bracketed-segments"];
        settings = {
          scan_timeout = 250; #ms
        };
      };

      # ls replacement
      programs.eza = {
        enable = true;
        icons = "auto";
        enableBashIntegration = true;
        enableZshIntegration = true;
        enableFishIntegration = true;
        git = true;

        extraOptions = [
          "--group-directories-first"
          "--no-quotes"
          "--header" # Show header row
          "--git-ignore"
          "--icons=always"
          # "--time-style=long-iso" # ISO 8601 extended format for time
          "--classify" # append indicator (/, *, =, @, |)
          "--hyperlink" # make paths clickable in some terminals
        ];
      };
      # Aliases to make `ls`, `ll`, `la` use eza
      home.shellAliases = {
        ls = "eza";
        lt = "eza --tree --level=2";
        ll = "eza  -lh --no-user --long";
        la = "eza -lah ";
        tree = "eza --tree ";
      };

      # cat replacement
      programs.bat = {
        enable = true;
        config = {
          pager = "less -FR";
          # other styles available and cane be combined
          #  style = "numbers,changes,headers,rule,grid";
          style = "full";
          # Bat has other thems as well
          # ansi,Catppuccin,base16,base16-256,GitHub,Nord,etc
          theme = lib.mkForce "Dracula";
        };
        extraPackages = with pkgs.bat-extras; [
          batman
          batpipe
          batgrep
        ];
      };
      home.sessionVariables = {
        MANPAGER = "sh -c 'col -bx | bat -l man -p'";
        MANROFFOPT = "-c";
      };
    };
  };
}
