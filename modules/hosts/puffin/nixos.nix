{config, ...}: {
  nixos.puffin = {
    system = "aarch64-linux";
    users = ["wyn" "deploy"];
    modules = with config.modules.nixos;
      [rpi5 nix-settings network security]
      ++ [system users sops tailscale deploy]
      ++ [
        {
          nixos = {
            users = {
              wyn = {
                isAdmin = true;
                sshKeys = [../../common/keys/openssh_key.pub];
                shell = "bash";
              };
              deploy = {
                isDeployer = true;
                sshKeys = [../../common/keys/deploy_key.pub];
                shell = "bash";
              };
            };
          };
        }
      ];
  };
}
