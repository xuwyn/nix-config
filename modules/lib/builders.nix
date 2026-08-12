{
  inputs,
  lib,
  config,
  self,
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
              inherit inputs self;
              inherit (cfg) host users;
              inherit (config) flake;
            };
            modules =
              cfg.modules
              ++ [
                (_: {
                  nixpkgs = {
                    inherit overlays;
                    hostPlatform = cfg.system;
                    config.allowUnfree = true;
                  };
                })
              ];
          }
      )
      config.nixos;

    darwinConfigurations =
      lib.mapAttrs (
        name: cfg:
          inputs.nix-darwin.lib.darwinSystem {
            inherit (cfg) system;
            specialArgs = {
              inherit inputs self;
              inherit (cfg) host users;
              inherit (config) flake;
            };
            modules =
              cfg.modules
              ++ [
                (_: {
                  nixpkgs.pkgs = import inputs.nixpkgs-stable {
                    inherit overlays;
                    inherit (cfg) system;
                    config.allowUnfree = true;
                  };
                })
              ];
          }
      )
      config.darwin;

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
              inherit inputs self;
              inherit (cfg) system username;
              inherit (config) flake;
            };
            modules = cfg.modules ++ [(_: {nixpkgs.config.allowUnfree = true;})];
          }
      )
      config.home;
  };
}
