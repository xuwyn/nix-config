{
  types,
  flakeInputs,
  ...
}: {
  inputs.nixpkgs.from = {parent}: parent.nixpkgs;

  options = {
    theme = {
      type = types.attrs;
      defaultFunc = {inputs}:
        (flakeInputs.spicetify-nix.legacyPackages.${inputs.nixpkgs.pkgs.stdenv.hostPlatform.system}).themes.catppuccin;
    };
    colorScheme = {
      type = types.string;
      default = "mocha";
    };
    enabledExtensions = {
      type = types.listOf types.attrs;
      defaultFunc = {inputs}:
        with (flakeInputs.spicetify-nix.legacyPackages.${inputs.nixpkgs.pkgs.stdenv.hostPlatform.system}).extensions; [
          adblockify
          hidePodcasts
          shuffle
        ];
    };
    extraSettings = {
      type = types.attrs;
      default = {};
    };
  };

  impl = {
    options,
    inputs,
  }: let
    unfreePkgs = import flakeInputs.nixpkgs {
      inherit (inputs.nixpkgs.pkgs.stdenv.hostPlatform) system;
      config.allowUnfreePredicate = pkg: builtins.elem (inputs.nixpkgs.lib.getName pkg) ["spotify"];
    };
  in
    flakeInputs.spicetify-nix.lib.mkSpicetify unfreePkgs ({
        inherit (options) theme colorScheme enabledExtensions;
      }
      // options.extraSettings);
}
