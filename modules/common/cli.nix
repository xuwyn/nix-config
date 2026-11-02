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
    packages = with self.wrapperModules.${system}; [
      (zsh {})
      (bash {})
      (tealdeer {})
      (ff {})
      (ns {})
      (nh {})
      (shop {})
    ];
  in {
    environment.systemPackages = packages;
    hj.packages = packages;
  };
}
