{
  self,
  lib,
  config,
  users,
  system,
  ...
}: let
  owner = lib.head users;
  sopsFile = ./sops/git.yaml;
in {
  environment.systemPackages = [(self.wrapperModules.${system}.git {})];

  sops.secrets = {
    git_key = {
      inherit owner sopsFile;
      path = "${config.hj.directory}/.ssh/id_ed25519";
    };
    git_key_pub = {
      inherit owner sopsFile;
      path = "${config.hj.directory}/.ssh/id_ed25519.pub";
    };
  };
}
