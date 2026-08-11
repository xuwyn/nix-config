{config, ...}: {
  darwin.apricot = {
    users = ["wyn" "deploy"];
    modules = with config.modules.darwin;
      [nix-settings system sops tailscale deploy users network security]
      ++ [
        {
          darwin.users = {
            wyn.sshKeys = [../../common/keys/openssh_key.pub];
            deploy.sshKeys = [../../common/keys/deploy_key.pub];
          };
        }
      ];
  };
}
