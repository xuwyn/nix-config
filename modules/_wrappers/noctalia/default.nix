{
  types,
  flakeInputs,
  ...
} @ adios: {
  options = {
    desktop = {
      type = types.attrs;
      default = {};
    };
    package.default = adios.promise ({inputs}: flakeInputs.noctalia.packages.${inputs.nixpkgs.pkgs.stdenv.hostPlatform.system}.default);
    extraSettings = {
      type = types.attrs;
      default = {};
    };
    settings.default = adios.promise ({
      options,
      inputs,
    }:
      inputs.nixpkgs.lib.recursiveUpdate
      (import ./settings.nix {
        monitors = map (m: m.name) options.desktop.monitors;
        inherit (inputs.nixpkgs) lib;
      })
      options.extraSettings);
  };
}
