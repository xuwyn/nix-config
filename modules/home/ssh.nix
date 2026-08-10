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
      type = lib.types.attrsOf (lib.types.submodule ({
        name,
        config,
        ...
      }: {
        options = {
          hostname = lib.mkOption {
            type = lib.types.str;
            default = name;
            description = "Can be IP address, .local, tailnet, etc. Defaults to the attribute name";
          };
          port = lib.mkOption {
            type = lib.types.nullOr lib.types.port;
            default = null;
            description = "Non-default SSH port, if any";
          };
        };
      }));
      default = {};
      description = "Other hosts in the flake to connect via ssh";
    };

    config = {
      sops.secrets.openssh_key = {};
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings =
          lib.mapAttrs
          (name: h:
            {
              inherit (h) hostname;
              user = username;
              identityFile = config.sops.secrets.openssh_key.path;
              identitiesOnly = true;
            }
            // lib.optionalAttrs (h.port != null) {inherit (h) port;})
          cfg.hosts;
      };
    };
  };
}
