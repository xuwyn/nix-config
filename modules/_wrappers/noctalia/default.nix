{
  types,
  flakeInputs,
  username,
  ...
} @ adios: {
  options = {
    desktop = {
      type = types.attrs;
      default = {};
    };
    package.default = adios.promise ({inputs}: flakeInputs.noctalia.packages.${inputs.nixpkgs.pkgs.stdenv.hostPlatform.system}.default);
    # package.default = adios.promise ({inputs}: let
    #   pkgs = inputs.nixpkgs.pkgs;
    # in
    #   pkgs.writeShellScriptBin "noctalia" ''
    #     exec /home/${username}/Documents/noctalia/build-debug/noctalia "$@"
    #   ''
    #   // {
    #     pname = "noctalia";
    #     meta.mainProgram = "noctalia";
    #   });
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
        inherit (options.desktop) monitors;
        inherit (inputs.nixpkgs) lib;
      })
      options.extraSettings);
  };
}
