{
  modules = let
    commonTailscaleSettings = {
      pkgs,
      inputs,
      ...
    }: {
      sops.secrets.tailscale_key.sopsFile = ./sops/tailscale.yaml;
      services.tailscale = {
        enable = true;
        package = inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.tailscale;
      };
    };
  in {
    nixos.tailscale = {config, ...}: {
      imports = [commonTailscaleSettings];
      services.tailscale.authKeyFile = config.sops.secrets.tailscale_key.path;

      # Allow traffic from tailscale
      networking = {
        nftables.enable = true;
        firewall = {
          enable = true;
          trustedInterfaces = [config.services.tailscale.interfaceName];
          allowedUDPPorts = [config.services.tailscale.port];
          checkReversePath = "loose";
        };
      };

      # Force tailscaled to use nftables (Critical for clean nftables-only systems)
      # This avoids the "iptables-compat" translation layer issues.
      systemd.services.tailscaled.serviceConfig.Environment = [
        "TS_DEBUG_FIREWALL_MODE=nftables"
      ];

      # Optimization: Prevent systemd from waiting for network online
      # (Optional but recommended for faster boot with VPNs)
      systemd.network.wait-online.enable = false;
      boot.initrd.systemd.network.wait-online.enable = false;
    };

    darwin.tailscale = {config, ...}: {
      imports = [commonTailscaleSettings];

      # Tailscale for nix-darwin doesn't have authKeyFile
      # start a launchd service to start tailscale with auth
      launchd.daemons.tailscale-auth = {
        serviceConfig = {
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
  };
}
