{
  modules.darwin.homebrew = {
    lib,
    config,
    inputs,
    ...
  }: let
    cfg = config.darwin.homebrew;
  in {
    options.darwin.homebrew = {};
    imports = [inputs.nix-homebrew.darwinModules.nix-homebrew];
    config = {
      nix-homebrew = {
        enable = true;
        enableRosetta = true;
        user = config.system.primaryUser;
        taps = {
          "homebrew/homebrew-core" = inputs.homebrew-core;
          "homebrew/homebrew-cask" = inputs.homebrew-cask;
        };
        mutableTaps = false;
      };
      homebrew = {
        enable = true;
        onActivation = {
          cleanup = "zap";
          autoUpdate = false;
          upgrade = false;
        };
        taps = builtins.attrNames config.nix-homebrew.taps;
      };
    };
  };
}
