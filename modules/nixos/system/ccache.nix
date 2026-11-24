{
  platforms = ["linux"];
  tags = ["desktop"];
  module = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.custom.ccache;
    cacheDir = config.programs.ccache.cacheDir;
  in {
    options.custom.ccache = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "ccache for selected packages";
      };

      packages = lib.mkOption {
        type = lib.types.attrsOf (lib.types.functionTo lib.types.package);
        default = {};
        description = ''
          Packages to build with ccacheStdenv. Each name becomes an attribute
          in pkgs, defined by a function from pkgs to the package to wrap.
        '';
      };
    };

    config = lib.mkIf cfg.enable {
      programs.ccache = {
        enable = true;
        cacheDir = "/nix/var/cache/ccache";
      };

      nix.settings.extra-sandbox-paths = [cacheDir];

      nixpkgs.overlays = [
        (final: prev: {
          ccacheWrapper = prev.ccacheWrapper.override {
            extraConfig = ''
              export CCACHE_COMPRESS=1
              export CCACHE_DIR="${cacheDir}"
              export CCACHE_UMASK=007
              export CCACHE_SLOPPINESS=random_seed
              if [ ! -w "$CCACHE_DIR" ]; then
                echo "ccache dir '$CCACHE_DIR' missing or not writable by $(whoami)" >&2
                exit 1
              fi
            '';
          };
        })

        # TODO: How to apply nested stdenv? Idk so this is a work around 😭
        # https://github.com/NixOS/nixpkgs/blob/ea2d730fbdbbb052b19f13fabdb8c7419e77be2a/pkgs/stdenv/adapters.nix#L321-L359
        # gcc >12.1.0 supports '-fuse-ld=mold'
        (final: prev:
          lib.mapAttrs
          (_: pkg:
            ((pkg prev).override {stdenv = prev.ccacheStdenv;}).overrideAttrs (old: {
              nativeBuildInputs = (old.nativeBuildInputs or []) ++ [prev.mold];
              env =
                (old.env or {})
                // {
                  NIX_CFLAGS_LINK = toString ((old.env or {}).NIX_CFLAGS_LINK or "") + " -fuse-ld=mold";
                };
            }))
          cfg.packages)
      ];
    };
  };
}
