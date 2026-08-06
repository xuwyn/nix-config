{
  modules.homeManager.ssh = {
    lib,
    config,
    username,
    ...
  }: let
    cfg = config.homeManager.ssh;
  in {
    options.homeManager.ssh.hosts = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule ({config, ...}: {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "Host alias";
          };
          hostname = lib.mkOption {
            type = lib.types.str;
            default = config.name;
            description = "Can be IP address, .local, tailnet, etc. Defaults to `name`";
          };
          port = lib.mkOption {
            type = lib.types.nullOr lib.types.port;
            default = null;
            description = "Non-default SSH port, if any";
          };
        };
      }));
      default = [];
      description = "Other hosts in the flake to connect via ssh";
    };

    config = {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings = builtins.listToAttrs (map
          (h: {
            name = h.name;
            value =
              {
                hostname = h.hostname;
                user = username;
                identityFile = config.sops.secrets.openssh_key.path;
                identitiesOnly = true;
              }
              // lib.optionalAttrs (h.port != null) {inherit (h) port;};
          })
          cfg.hosts);
      };
    };
  };
}
