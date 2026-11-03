{
  hjemCompat = true;
  module = {
    self,
    system,
    ...
  }: let
    packages = with self.wrapperModules.${system}; [
      (zsh {})
      (bash {})
      (tealdeer {})
      (ns {})
      (nh {})
      (shop {})
    ];
  in {
    environment.systemPackages = packages;
    hj.packages = packages;
  };
}
