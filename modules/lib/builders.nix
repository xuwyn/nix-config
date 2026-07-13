{
  inputs,
  lib,
  config,
  ...
}: let
  overlays = import ../_overlays {inherit inputs;};
in {
  config = {
    nixosConfigurations =
      lib.mapAttrs (
        name: cfg:
          inputs.nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs;
              inherit (cfg) host users profile;
            };
            modules =
              cfg.modules
              ++ [
                config.modules.nixos.${cfg.profile}
                (_: {
                  nixpkgs = {
                    inherit overlays;
                    config.allowUnfree = true;
                  };
                })
              ];
          }
      )
      config.nixos;

    homeConfigurations =
      lib.mapAttrs (
        name: cfg: let
          isMac = cfg.system == "aarch64-darwin" || cfg.system == "x86_64-darwin";
          hmLib =
            if isMac
            then inputs.home-manager-stable.lib
            else inputs.home-manager.lib;
          chosenNixpkgs =
            if isMac
            then inputs.nixpkgs-stable
            else inputs.nixpkgs;
        in
          hmLib.homeManagerConfiguration {
            pkgs = import chosenNixpkgs {
              inherit (cfg) system;
              inherit overlays;
              config.allowUnfree = true;
            };
            extraSpecialArgs = {
              inherit inputs;
              inherit (cfg) system username;
            };
            modules = cfg.modules;
          }
      )
      config.home;
  };
}
