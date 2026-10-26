{
  sv = ''sudo env "PATH=$PATH" nvim'';
  v = "nvim";
  c = "clear";
  ".." = "cd ..";

  cow = ", fortune | , cowsay | , lolcat";
  mvs = "nix run github:fzakaria/nixpkgs-multiverse#mvs -- ";
  ncr = "nix run github:greyxp1/ncr -- ";
  nix-graph = "nix run github:AlexAntonik/nix-graph -- ";
  tack = "nix run github:manic-systems/tack -- ";

  hjsw = ''hjem standalone switch --flake-attr=hjemConfigurations.\"$USER@$HOST\" --flake=$HOME/nix-config'';
  hjgc = "hjem standalone expire-generations --keep-last 1";
  ncg = "nix-collect-garbage --delete-old && nix-collect-garbage -d && nix-store --gc && nix-store --optimise";

  apos = "attic push main /run/current-system";
  ainf = "attic cache info main";

  ls = "eza";
  lt = "eza --tree --level=2";
  ll = "eza  -lh --no-user --long";
  la = "eza -lah ";
  tree = "eza --tree ";
  code = "eza --code";

  gr = "git restore";
  gl = "git log --graph --pretty=format:\"%Cred%h%Creset - %C(yellow)%d%Creset %s %C(green)(%cr)%C(bold blue) <%an>%Creset\" --abbrev-commit";
  gs = "git status";
  gd = "git diff";
  ga = "git add .";
  gb = "git branch -a";
}
