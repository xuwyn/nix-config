{
  modules = let
    mkAtticOptions = lib: {
      tailscaleDomain = lib.mkOption {
        type = lib.types.str;
        default = "puffin.tail9fb2b9.ts.net";
        description = "Tailnet of the cache server";
      };
      cacheName = lib.mkOption {
        type = lib.types.str;
        default = "main";
        description = "This config's cache entry";
      };
      publicKey = lib.mkOption {
        type = lib.types.str;
        default = "AOInzGo25vK/CX+//GtecGc5zoePljsTyLki/rliiS8=";
        description = "This cache's public key from `attic cache info <cache>`";
      };
    };

    mkAtticPullConfig = {
      config,
      lib,
      cfg,
    }: {
      # TODO: Every caches use the same token... ¯\_(ツ)_/¯
      sops.secrets.attic_token.sopsFile = ./sops/access-tokens.yaml;
      sops.templates.".netrc".content = ''
        machine ${cfg.tailscaleDomain}
        password ${config.sops.placeholder.attic_token}
      '';
      nix.settings = {
        extra-substituters = ["https://${cfg.tailscaleDomain}/${cfg.cacheName}"];
        extra-trusted-public-keys = ["${cfg.cacheName}:${cfg.publicKey}"];
      };
    };

    mkSystemAtticModule = class: {
      config,
      lib,
      ...
    }: let
      cfg = config.${class}.attic;
    in {
      options.${class}.attic = mkAtticOptions lib;
      config = mkAtticPullConfig {inherit config lib cfg;};
    };
  in {
    nixos.attic = mkSystemAtticModule "nixos";
    darwin.attic = mkSystemAtticModule "darwin";
    homeManager.attic = {
      config,
      lib,
      ...
    }: let
      cfg = config.homeManager.attic;
    in {
      options.homeManager.attic =
        {
          defaultServer = lib.mkOption {
            type = lib.types.enum ["tailscale"];
            default = "tailscale";
          };
        }
        // mkAtticOptions lib;

      config = lib.mkMerge [
        (mkAtticPullConfig {inherit config lib cfg;})
        {
          programs.attic-client = {
            enable = true;
            settings = {
              default-server = cfg.defaultServer;
              servers = {
                tailscale = {
                  endpoint = "https://${cfg.tailscaleDomain}";
                  token-file = config.sops.secrets.attic_token.path;
                };
              };
            };
          };
        }
      ];
    };
  };
}
