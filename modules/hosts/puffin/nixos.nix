{config, ...}: {
  nixos.puffin = {
    system = "aarch64-linux";
    users = ["wyn" "deploy"];
    modules = with config.modules.nixos;
      [nix-settings drivers network security]
      ++ [system users sops tailscale deploy]
      ++ [
        {
          nixos = {
            drivers.rpi5.enable = true;
            users = {
              wyn = {
                isAdmin = true;
                sshKeys = [../../common/keys/openssh_key.pub];
              };
              deploy = {
                isDeployer = true;
                sshKeys = [../../common/keys/deploy_key.pub];
              };
            };
          };
        }
      ];
  };
}
