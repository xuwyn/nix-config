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

    mkAtticConfig = {
      config,
      lib,
      cfg,
      pkgs,
      users,
      ...
    }: let
      tomlFormat = pkgs.formats.toml {};
    in {
      # TODO: Every host uses the same token for all caches... ¯\_(ツ)_/¯
      sops.secrets.attic_token = {
        owner = lib.head users;
        sopsFile = ./sops/access-tokens.yaml;
      };
      sops.templates.".netrc".content = ''
        machine ${cfg.tailscaleDomain}
        password ${config.sops.placeholder.attic_token}
      '';
      nix.settings = {
        extra-substituters = ["https://${cfg.tailscaleDomain}/${cfg.cacheName}"];
        extra-trusted-public-keys = ["${cfg.cacheName}:${cfg.publicKey}"];
      };
      environment.systemPackages = [pkgs.attic-client];
      hj.xdg.config.files."attic/config.toml".source = tomlFormat.generate "attic-config.toml" {
        default-server = "tailscale";
        servers.tailscale = {
          endpoint = "https://${cfg.tailscaleDomain}";
          token-file = config.sops.secrets.attic_token.path;
        };
      };
    };

    mkSystemAtticModule = class: {
      config,
      lib,
      pkgs,
      users,
      ...
    }: let
      cfg = config.${class}.attic;
    in {
      options.${class}.attic = mkAtticOptions lib;
      config = mkAtticConfig {inherit config lib cfg pkgs users;};
    };
  in {
    nixos.attic = mkSystemAtticModule "nixos";
    darwin.attic = mkSystemAtticModule "darwin";
  };
}
