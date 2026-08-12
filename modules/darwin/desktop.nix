{
  modules.darwin.desktop = {
    lib,
    config,
    inputs,
    pkgs,
    ...
  }: let
    cfg = config.darwin.desktop;
  in {
    options.darwin.desktop = {
      omniwm.enable = lib.mkEnableOption "Enable OmniWM";
    };
    config = lib.mkMerge [
      (lib.mkIf cfg.omniwm.enable {
        nix-homebrew.taps."BarutSRB/homebrew-tap" = inputs.barutsrb-tap;
        homebrew.casks = ["BarutSRB/tap/omniwm"];

        # Auto start
        launchd.user.agents.omniwm = {
          serviceConfig = {
            ProgramArguments = ["/Applications/OmniWM.app/Contents/MacOS/OmniWM"];
            KeepAlive = true;
            RunAtLoad = true;
            LimitLoadToSessionType = "Aqua";
            StandardOutPath = "/tmp/omniwm.log";
            StandardErrorPath = "/tmp/omniwm.err.log";
          };
        };
      })
    ];
  };
}
