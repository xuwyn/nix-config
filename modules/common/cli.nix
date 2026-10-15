{
  self,
  system,
  ...
}: {
  environment.systemPackages = with self.wrapperModules.${system}; [
    (zsh {})
    (bash {})
    (tealdeer {})
    (ff {})
    (ns {})
    (nh {})
  ];
}
