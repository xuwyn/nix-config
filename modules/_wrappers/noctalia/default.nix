{
  types,
  flakeInputs,
  ...
}: {
  options = {
    monitors = {
      type = types.listOf types.string;
      description = "Monitor names used for per-monitor lockscreen widgets.";
    };
    package.defaultFunc = {inputs}: flakeInputs.noctalia.packages.${inputs.nixpkgs.pkgs.stdenv.hostPlatform.system}.default;
    settings.defaultFunc = {
      options,
      inputs,
    }:
      import ./settings.nix {
        inherit (options) monitors;
        inherit (inputs.nixpkgs) lib;
      };
  };
}
