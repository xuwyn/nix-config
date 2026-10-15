{
  platforms = ["darwin"];
  module = {
    config,
    lib,
    inputs,
    system,
    ...
  }: {
    options.custom.tailscale.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Tailscale daemon, plus a launchd job that authenticates it from the sops key";
    };

    config = lib.mkIf config.custom.tailscale.enable {
      sops.secrets.tailscale_key.sopsFile = ../common/sops/tailscale.yaml;

      services.tailscale = {
        enable = true;
        package = inputs.nixpkgs.legacyPackages.${system}.tailscale;
      };

      # Tailscale for nix-darwin doesn't have authKeyFile
      # start a launchd service to start tailscale with auth
      launchd.daemons.tailscale-auth.serviceConfig = {
        Label = "com.tailscale.auth";
        ProgramArguments = [
          "/bin/sh"
          "-c"
          "${config.services.tailscale.package}/bin/tailscale up --auth-key=file:${config.sops.secrets.tailscale_key.path}"
        ];
        WatchPaths = ["/var/run/tailscaled.socket"];
        RunAtLoad = false;
      };
    };
  };
}
