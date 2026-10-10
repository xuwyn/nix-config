_: let
  mkGitModule = {
    self,
    lib,
    config,
    pkgs,
    users,
    ...
  }: {
    environment.systemPackages = [(self.wrapperModules.${pkgs.stdenv.hostPlatform.system}.git {})];
    sops.secrets = let
      owner = lib.head users;
      sopsFile = ./sops/git.yaml;
    in {
      git_key = {
        inherit owner sopsFile;
        path = "${config.hj.directory}/.ssh/id_ed25519";
      };
      git_key_pub = {
        inherit owner sopsFile;
        path = "${config.hj.directory}/.ssh/id_ed25519.pub";
      };
    };
  };
in {
  modules = {
    nixos.git = mkGitModule;
    darwin.git = mkGitModule;
  };
}
