_: let
  mkSshModule = class: {
    config,
    lib,
    users,
    ...
  }: let
    cfg = config.${class}.ssh;
  in {
    options.${class}.ssh = {
      username = lib.mkOption {
        type = lib.types.str;
        default = lib.head users;
        description = "User identity for ssh connection";
      };
      hosts = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
          options = {
            hostname = lib.mkOption {
              type = lib.types.str;
              default = name;
              description = "IP, .local, tailnet address, etc. Defaults to the attr name";
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
    };

    config = {
      sops.secrets.openssh_key = {
        owner = lib.head users;
        sopsFile = ./sops/ssh.yaml;
      };

      hj.files.".ssh/config" = let
        hostBlock = name: h: ''
          Host ${name}
            hostName ${h.hostname}
            user ${cfg.username}
            identityFile ${config.sops.secrets.openssh_key.path}
            identitiesOnly yes
            ${lib.optionalString (h.port != null) "port ${toString h.port}"}
        '';
      in {
        text = lib.concatStringsSep "\n" (lib.mapAttrsToList hostBlock cfg.hosts);
      };
    };
  };
in {
  modules = {
    nixos.ssh = mkSshModule "nixos";
    darwin.ssh = mkSshModule "darwin";
  };
}
