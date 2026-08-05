{config, ...}: {
  darwin.apricot = {
    users = ["wyn"];
    modules = with config.modules.darwin; [
      nix-settings
      system
      sops
      users
      network
      security
    ];
  };
}
