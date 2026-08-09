{lib, ...}: {
  modules = let
    commonUserOptions = {lib, ...}: {
      options = {
        shell = lib.mkOption {
          type = lib.types.enum ["zsh" "bash" "fish"];
          default = "zsh";
          description = "Default login shell for this user";
        };
        sshKeys = lib.mkOption {
          type = lib.types.listOf lib.types.path;
          default = [];
          description = "Public key files for SSH login";
        };
      };
    };

    shellPackages = pkgs: {
      zsh = pkgs.zsh;
      bash = pkgs.bash;
      fish = pkgs.fish;
    };

    mkShellsInUse = users: lib.unique (map (u: u.shell) (lib.attrValues users));

    mkShellProgramsConfig = shellsInUse: {
      programs.zsh.enable = lib.mkIf (builtins.elem "zsh" shellsInUse) true;
      programs.bash.enable = lib.mkIf (builtins.elem "bash" shellsInUse) true;
      programs.fish.enable = lib.mkIf (builtins.elem "fish" shellsInUse) true;
    };
  in {
    nixos.users = {
      pkgs,
      lib,
      config,
      ...
    }: {
      options.nixos.users = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          imports = [commonUserOptions];
          options = {
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

      config = let
        shellPkgs = shellPackages pkgs;
        shellsInUse = mkShellsInUse config.nixos.users;
      in
        {
          users.mutableUsers = !(config ? sops);
          users.users = lib.mapAttrs (name: u:
            {
              isNormalUser = true;
              description = name;
              extraGroups =
                ["networkmanager" "video" "render" "input" "i2c"]
                ++ lib.optional u.isAdmin "wheel"
                ++ u.extraGroups;
              shell = shellPkgs.${u.shell};
            }
            // lib.optionalAttrs (u.sshKeys != []) {
              openssh.authorizedKeys.keyFiles = u.sshKeys;
            }
            // lib.optionalAttrs (config ? sops && config.sops.secrets ? "${name}_password") {
              hashedPasswordFile = config.sops.secrets."${name}_password".path;
            })
          config.nixos.users;
        }
        // mkShellProgramsConfig shellsInUse;
    };

    darwin.users = {
      pkgs,
      lib,
      config,
      users,
      ...
    }: {
      options.darwin.users = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          imports = [commonUserOptions];
        });
        default = {};
        description = "Per-user account configuration (macOS account must already exist)";
      };

      config = let
        shellPkgs = shellPackages pkgs;
        shellsInUse = mkShellsInUse config.darwin.users;
      in
        {
          environment.shells = map (s: shellPkgs.${s}) shellsInUse;

          users.users = lib.mapAttrs (name: u:
            {
              home = "/Users/${name}";
              shell = shellPkgs.${u.shell};
            }
            // lib.optionalAttrs (u.sshKeys != []) {
              openssh.authorizedKeys.keyFiles = u.sshKeys;
            })
          config.darwin.users;

          system.primaryUser = lib.head users;
        }
        // mkShellProgramsConfig shellsInUse;
    };
  };
}
