{
  modules.nixos.services = {
    config,
    lib,
    pkgs,
    inputs,
    ...
  }: let
    cfg = config.nixos.services.waydroid;
  in
    with lib; {
      options.nixos.services.waydroid = {
        enable = mkEnableOption "Enable Waydroid (purely for Arknights)";
      };

      # see: https://github.com/pioner14/Waydroid_on_NixOS/blob/main/Waydroid_Setup_Guide.md
      config = mkIf cfg.enable {
        virtualisation.waydroid = {
          enable = true;
          package = pkgs.waydroid-nftables;
        };

        services.geoclue2.enable = true;

        environment.systemPackages = [
          pkgs.android-tools # adb
          pkgs.wl-clipboard
          pkgs.waydroid-helper
          inputs.nur.legacyPackages.${pkgs.stdenv.hostPlatform.system}.repos.ataraxiasjel.waydroid-script
        ];

        systemd = {
          packages = [pkgs.waydroid-helper];
          services.waydroid-mount.wantedBy = ["multi-user.target"];

          services.waydroid-fix = {
            description = "Fix Waydroid Settings";
            before = ["waydroid-container.service"];
            wantedBy = ["waydroid-container.service"];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
              ExecStart = pkgs.writeShellScript "waydroid-fix" ''
                set -e
                CFG_FILE="/var/lib/waydroid/waydroid.cfg"

                if [ ! -f "$CFG_FILE" ]; then
                  echo "waydroid.cfg not found, skipping (run 'waydroid init' first)" >&2
                  exit 0
                fi

                set_prop() {
                  key="$1"
                  value="$2"
                  if ${pkgs.gnugrep}/bin/grep -qE "^''${key}[[:space:]]*=" "$CFG_FILE"; then
                    ${pkgs.gnused}/bin/sed -i "s|^''${key}[[:space:]]*=.*|''${key} = ''${value}|" "$CFG_FILE"
                  else
                    ${pkgs.gnused}/bin/sed -i "/^\[properties\]/a ''${key} = ''${value}" "$CFG_FILE"
                  fi
                }

                set_prop persist.waydroid.width 1600
                set_prop persist.waydroid.height 900

                ${pkgs.waydroid-nftables}/bin/waydroid upgrade --offline
              '';
            };
          };

          services.waydroid-container = {
            requires = ["waydroid-fix.service"];
            after = ["waydroid-fix.service"];
          };
        };
      };
    };
}
