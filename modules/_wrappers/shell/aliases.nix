{
  sv = "sudo -E nvim";
  v = "nvim";
  c = "clear";
  ".." = "cd ..";
  cow = "fortune | cowsay | lolcat";
  ncg = "nix-collect-garbage --delete-old && nix-collect-garbage -d && nix-store --gc && nix-store --optimise";

  apos = "attic push main /run/current-system";
  aphm = "attic push main $(readlink -f ~/.local/state/nix/profiles/home-manager)";
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
