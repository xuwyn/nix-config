# Source: https://github.com/Cbeck527/dotfiles-final-final-v2/blob/da66fb3b213972781c7c03ace011c38748c0bab8/lib/hjem.nix
# Evaluates modules for a hjem-only host (non-nixos distro)
#
# - `hj` is a real submodule built from hjem's platform-agnostic user.nix
# - Everything else (`programs.*`, `environment.*`, ...) are merged lazily,
#   never forced unless something reads it.
#
# Returns { manifest, packages }
{
  lib,
  inputs,
}: {
  pkgs,
  user,
  home,
  system ? pkgs.stdenv.hostPlatform.system,
  specialArgs ? {},
  modules ? [],
}: let
  hjem = inputs.hjem;
  hjem-lib = hjem.hjem-lib.${system};

  eval = lib.evalModules {
    specialArgs = specialArgs // {inherit pkgs hjem-lib;};
    modules =
      [
        {
          options.hj = lib.mkOption {
            default = {};
            type = lib.types.submoduleWith {
              class = "hjem"; # must match `_class` in user.nix
              specialArgs = {inherit pkgs hjem-lib;};
              modules = [
                "${hjem}/modules/common/user.nix"
                {
                  _module.args.name = user;
                  inherit user;
                  directory = home;
                  clobberFiles = true;
                }
              ];
            };
          };
          config._module.freeformType = lib.types.lazyAttrsOf lib.types.anything;
        }
      ]
      ++ modules;
  };

  cfg = eval.config.hj;

  files =
    lib.pipe [
      cfg.files
      cfg.xdg.cache.files
      cfg.xdg.config.files
      cfg.xdg.data.files
      cfg.xdg.state.files
    ] [
      (lib.concatMap lib.attrValues)
      (lib.filter (f: f.enable))
      (map hjem-lib.fileToJson)
    ];

  manifest = {
    version = 3;
    inherit files;
  };

  failed = map (a: a.message) (lib.filter (a: !a.assertion) cfg.assertions);
in
  lib.throwIf (failed != [])
  ''
    Failed hjem assertions for ${user}:
    ${lib.concatMapStringsSep "\n" (m: "- ${m}") failed}
  ''
  (
    lib.showWarnings cfg.warnings {
      inherit manifest;
      inherit (cfg) packages;
    }
  )
