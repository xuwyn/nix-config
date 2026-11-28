{
  types,
  merge,
  promise,
  flakeInputs,
  ...
}: {
  inputs = {
    mkWrapper.from = {parent}: parent.mkWrapper;
    nixpkgs.from = {parent}: parent.nixpkgs;
  };

  options = {
    settings = {
      type = types.attrs;
      merge = merge.attrs.recursively;
      default = {
        animations = {
          enabled = false;
          events.directory_open = "none";
        };

        appearance.background_opacity = 1;

        font = {
          family = "sans-serif";
          monospace = "monospace";
        };

        pointer = {
          double_click_ms = 400;
          double_click_distance = 4;
        };

        icon = {
          theme = "builtin";
          follow_accent = true;
        };

        startup.mode = "home";

        keyboard = {
          wrap = true;
          vim = true;
        };

        photos.enabled = false;

        previews = {
          media = true;
          pdf = true;
        };
      };
    };

    package = {
      type = types.derivation;
      default =
        promise ({inputs}:
          flakeInputs.rummage.packages.${inputs.nixpkgs.pkgs.stdenv.hostPlatform.system}.rummage-with-photos);
    };
  };

  inputs.mkWrapper.options = promise (
    {
      options,
      inputs,
    }: let
      generator = inputs.nixpkgs.pkgs.formats.toml {};
    in {
      inherit (options) package;
      symlinks = {
        "$out/rummage/config.toml" =
          if options ? settings
          then generator.generate "config.toml" options.settings
          else null;
      };
      flags =
        if options ? settings
        then [
          "--config"
          "$out/rummage/config.toml"
        ]
        else [];
    }
  );

  result = promise ({results}: results.mkWrapper);
}
