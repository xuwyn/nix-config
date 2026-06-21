{
  pkgs,
  inputs,
  ...
}: {
  home.packages = [
    # inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
