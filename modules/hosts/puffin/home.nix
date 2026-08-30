{config, ...}: {
  home."wyn@puffin" = {
    system = "aarch64-linux";
    username = "wyn";
    modules = with config.modules.homeManager;
      [nix-settings home sops ssh deploy cli]
      ++ [
        {
          homeManager = {
            # attic = {
            #   defaultServer = "lan";
            #   tailscaleDomain = null;
            # };
            ssh.hosts = {
              apricot = {};
              mango = {};
              capybara = {};
              potato = {};
              "apricot.local" = {};
              "mango.local" = {};
              "capybara.local" = {};
              "potato.local" = {};
            };
            cli = {
              bash.enable = true;
              nh.enable = true;
              tealdeer.enable = true;
              search.enable = true;
            };
          };
        }
      ];
  };
}
