{
  modules = let
    mkAtticOptions = lib: {
      tailscaleDomain = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "puffin.tail9fb2b9.ts.net";
        description = "Tailnet of the cache server";
      };
      lanDomain = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "puffin.local";
        description = "LAN fallback. Null to omit";
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
      assertions = [
        {
          assertion = cfg.tailscaleDomain != null || cfg.lanDomain != null;
          message = "attic: at least one of tailscaleDomain or lanDomain must be set";
        }
      ];
      # TODO: Every caches use the same token... ¯\_(ツ)_/¯
      sops.secrets.attic_token.sopsFile = ./sops/access-tokens.yaml;
      sops.templates."attic-netrc".content = lib.concatStringsSep "\n" (
        lib.optionals (cfg.tailscaleDomain != null) [
          "machine ${cfg.tailscaleDomain}"
          "password ${config.sops.placeholder.attic_token}"
          ""
        ]
        ++ lib.optionals (cfg.lanDomain != null) [
          "machine ${cfg.lanDomain}"
          "password ${config.sops.placeholder.attic_token}"
        ]
      );
      nix.settings = {
        substituters =
          lib.optionals (cfg.tailscaleDomain != null) ["https://${cfg.tailscaleDomain}/${cfg.cacheName}"]
          ++ lib.optionals (cfg.lanDomain != null) ["https://${cfg.lanDomain}/${cfg.cacheName}"];
        trusted-public-keys = ["${cfg.cacheName}:${cfg.publicKey}"];
        netrc-file = config.sops.templates."attic-netrc".path;
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
      config = lib.mkMerge [
        (mkAtticPullConfig {inherit config lib cfg;})
        (lib.mkIf (cfg.lanDomain != null) {
          security.pki.certificateFiles = [./keys/atticd.crt];
        })
      ];
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
            type = lib.types.enum ["tailscale" "lan"];
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
              servers =
                lib.optionalAttrs (cfg.tailscaleDomain != null) {
                  tailscale = {
                    endpoint = "https://${cfg.tailscaleDomain}";
                    token-file = config.sops.secrets.attic_token.path;
                  };
                }
                // lib.optionalAttrs (cfg.lanDomain != null) {
                  lan = {
                    endpoint = "https://${cfg.lanDomain}";
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
