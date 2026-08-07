{config, ...}: {
  darwin.apricot = {
    users = ["wyn"];
    modules = with config.modules.darwin; [
      nix-settings
      system
      sops
      tailscale
      users
      network
      security
      {
        darwin.users.wyn.sshKeys = [../../common/keys/id_ed25519_openssh.pub];
      }
    ];
  };
}
