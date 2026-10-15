{
  platforms = ["darwin"];
  module = {
    config,
    lib,
    inputs,
    ...
  }: {
    imports = [inputs.nix-homebrew.darwinModules.nix-homebrew];

    options.custom.homebrew.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "nix-homebrew with declarative taps, and homebrew with zap cleanup";
    };

    config = lib.mkIf config.custom.homebrew.enable {
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
