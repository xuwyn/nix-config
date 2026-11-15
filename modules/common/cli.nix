{
  hjemCompat = true;
  module = {
    self,
    system,
    inputs,
    ...
  }: let
    packages = with self.wrapperModules.${system}; [
      (zsh {})
      (bash {})
      (tealdeer {})
      (ns {})
      (nh {})
      inputs.nix-index-database.packages.${system}.comma-with-db
    ];
  in {
    environment.systemPackages = packages;
    hj.packages = packages;
  };
}
