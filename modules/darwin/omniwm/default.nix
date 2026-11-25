{
  hjemCompat = true;
  tags = ["desktop"];
  platforms = ["darwin"];
  module = {
    config,
    inputs,
    flakePath,
    ...
  }: {
    nix-homebrew.taps."BarutSRB/homebrew-tap" = inputs.barutsrb-tap;
    homebrew.casks = ["BarutSRB/tap/omniwm"];

    hj.xdg.config.files."omniwm/settings.toml".source = "${config.hj.directory}/${flakePath}/modules/darwin/omniwm/settings.toml";
  };
}
