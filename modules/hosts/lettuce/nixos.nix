{config, ...}: {
  nixos.lettuce = {
    users = ["wyn"];
    modules = with config.modules.nixos; [wsl nix-settings sops system network attic tailscale];
  };
}
