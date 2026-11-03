{
  types,
  flakeInputs,
  ...
} @ adios: {
  inputs.nixpkgs.from = {parent}: parent.nixpkgs;

  options = {
    theme = {
      type = types.attrs;
      default =
        adios.promise ({inputs}:
          (flakeInputs.spicetify-nix.legacyPackages.${inputs.nixpkgs.pkgs.stdenv.hostPlatform.system}).themes.catppuccin);
    };
    colorScheme = {
      type = types.string;
      default = "mocha";
    };
    enabledExtensions = {
      type = types.listOf types.attrs;
      default = adios.promise ({inputs}:
        with (flakeInputs.spicetify-nix.legacyPackages.${inputs.nixpkgs.pkgs.stdenv.hostPlatform.system}).extensions; [
          adblockify
          shuffle
        ]);
    };
    extraSettings = {
      type = types.attrs;
      default = {};
    };
  };

  result = adios.promise ({
    options,
    inputs,
  }:
    flakeInputs.spicetify-nix.lib.mkSpicetify inputs.nixpkgs.pkgs ({
        inherit (options) theme colorScheme enabledExtensions;
      }
      // options.extraSettings));
}
