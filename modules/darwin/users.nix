{
  platforms = ["darwin"];
  module = {
    lib,
    config,
    users,
    ...
  }: let
    cfg = config.custom.users;
  in {
    options.custom.users = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          shell = lib.mkOption {
            type = lib.types.path;
            description = "Path to shell binary";
          };
          sshKeys = lib.mkOption {
            type = lib.types.listOf lib.types.path;
            default = [];
            description = "Public key files for SSH login";
          };
        };
      });
      default = {};
      description = "Per-user account configuration (macOS account must already exist)";
    };

    config = {
      environment.shells = lib.unique (map (u: u.shell) (lib.attrValues cfg));

      users.users = lib.mapAttrs (name: u:
        {
          home = "/Users/${name}";
          shell = u.shell;
        }
        // lib.optionalAttrs (u.sshKeys != []) {
          openssh.authorizedKeys.keyFiles = u.sshKeys;
        })
      cfg;

      system.primaryUser = lib.head users;
    };
  };
}
