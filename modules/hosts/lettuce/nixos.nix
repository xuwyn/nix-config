{config, ...}: {
  nixos.lettuce = {
    system = "x86_64-linux";
    users = ["wyn"];
    modules = with config.modules.nixos; [wsl nix-settings sops system];
  };
}
