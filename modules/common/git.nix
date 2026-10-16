{
  self,
  lib,
  config,
  users,
  system,
  ...
}: let
  cfg = config.custom.git;
  owner = lib.head users;
  sopsFile = ./sops/git.yaml;
in {
  options.custom.git.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Install the git wrapper and its SSH key secrets";
  };

  config = lib.mkIf cfg.enable {
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
  };
}
