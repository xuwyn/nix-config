{
  flake.modules.homeManager.bash = {...}: {
    programs.bash = {
      enable = true;
      enableCompletion = true;
      initExtra = ''
        fastfetch
      '';

      shellAliases = {
        sv = "sudo nvim";
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
      };
    };
  };
}
