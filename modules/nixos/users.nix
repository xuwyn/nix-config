{
  platforms = ["linux"];
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
          isAdmin = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether this user is granted wheel (sudo) access";
          };
          isDeployer = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether this user is a deploy-rs sudoer (not full wheel)";
          };
          extraGroups = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "Additional groups beyond the common defaults";
          };
        };
      });
      default = {};
      description = "Per-user account configuration";
    };

    config = {
      users.mutableUsers = lib.mkDefault false;

      users.users = lib.mapAttrs (name: u:
        {
          isNormalUser = !u.isDeployer;
          isSystemUser = u.isDeployer;
          description = name;
          group = lib.mkIf u.isDeployer "deploy";
          extraGroups =
            lib.optionals (!u.isDeployer) ["networkmanager" "video" "render" "input" "i2c"]
            ++ lib.optional u.isAdmin "wheel"
            ++ u.extraGroups;
          shell = u.shell;
        }
        // lib.optionalAttrs (u.sshKeys != []) {
          openssh.authorizedKeys.keyFiles = u.sshKeys;
        }
        // lib.optionalAttrs (!u.isDeployer) {
          hashedPasswordFile = lib.mkDefault config.sops.secrets."${name}_password".path;
        })
      cfg;

      users.groups = lib.mkIf (lib.any (u: u.isDeployer) (lib.attrValues cfg)) {deploy = {};};

      environment.shells = lib.unique (map (u: u.shell) (lib.attrValues cfg));

      sops.secrets = lib.listToAttrs (map (u: {
          name = "${u}_password";
          value = {neededForUsers = true;};
        })
        (lib.filter (u: !(cfg.${u}.isDeployer or false)) users));
    };
  };
}
