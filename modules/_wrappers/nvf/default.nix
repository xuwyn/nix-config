{
  types,
  flakeInputs,
  ...
} @ adios: {
  inputs = {
    nixpkgs.from = {parent}: parent.nixpkgs;
  };

  options = {
    extraSettings = {
      type = types.attrs;
      default = {};
    };
  };

  result = adios.promise ({
    options,
    inputs,
  }:
    (flakeInputs.nvf.lib.neovimConfiguration {
      pkgs = inputs.nixpkgs.pkgs;
      modules = [
        ./settings.nix
        ./keymaps.nix
        options.extraSettings
      ];
    }).neovim);
}
