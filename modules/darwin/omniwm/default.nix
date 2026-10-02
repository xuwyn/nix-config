{
  modules.darwin.omniwm = {
    lib,
    config,
    inputs,
    flake,
    ...
  }: {
    nix-homebrew.taps."BarutSRB/homebrew-tap" = inputs.barutsrb-tap;
    homebrew.casks = ["BarutSRB/tap/omniwm"];

    # OmniWM replaces the whole file instead of editing it
    # So symlink the entire folder, not ideal but it will do 😑
    hj.xdg.config.files."omniwm".source = "${config.hj.directory}/${flake.homeRelativePath}/modules/darwin/omniwm";
  };
}
