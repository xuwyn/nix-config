{
  config,
  lib,
  pkgs,
  users,
  inputs,
  system,
  ...
}: let
  cfg = config.custom.attic;
  tomlFormat = pkgs.formats.toml {};
in {
  options.custom.attic = {
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

  config = {
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

    environment.systemPackages = [inputs.nixpkgs.legacyPackages.${system}.attic-client];

    hj.xdg.config.files."attic/config.toml".source = tomlFormat.generate "attic-config.toml" {
      default-server = "tailscale";
      servers.tailscale = {
        endpoint = "https://${cfg.tailscaleDomain}";
        token-file = config.sops.secrets.attic_token.path;
      };
    };
  };
}
