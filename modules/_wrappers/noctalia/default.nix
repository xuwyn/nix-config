{
  types,
  flakeInputs,
  ...
} @ adios: {
  options = {
    monitors = {
      type = types.listOf types.string;
      description = "Monitor names used for per-monitor lockscreen widgets.";
    };
    package.default = adios.promise ({inputs}: flakeInputs.noctalia.packages.${inputs.nixpkgs.pkgs.stdenv.hostPlatform.system}.default);
    settings.default = adios.promise ({
      options,
      inputs,
    }:
      import ./settings.nix {
        inherit (options) monitors;
        inherit (inputs.nixpkgs) lib;
      });
  };
}
