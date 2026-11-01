{
  hjemCompat = true;
  module = {
    self,
    system,
    inputs,
    lib,
    config,
    ...
  }: let
    packages =
      (with self.wrapperModules.${system}; [
        (zsh {})
        (bash {})
        (tealdeer {})
        (ff {})
        (ns {})
        (nh {})
        # (shop {})
      ])
      ++ [
        inputs.nix-index-database.packages.${system}.comma-with-db
        inputs.nix-shop.packages.${system}.shop
        inputs.nix-index-database.packages.${system}.nix-index-with-db
      ];
  in {
    environment.systemPackages = packages;
    hj.packages = packages;
  };
}
