{...}: {
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
      ncg = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
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
}
