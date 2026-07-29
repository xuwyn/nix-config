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
                PROP_FILE="/var/lib/waydroid/waydroid.prop"
                mkdir -p /var/lib/waydroid
                touch "$PROP_FILE"
                chown root:root "$PROP_FILE"
                chmod 644 "$PROP_FILE"
                set_prop() {
                  ${pkgs.gnused}/bin/sed -i "/^$1=/d" "$PROP_FILE"
                  echo "$1=$2" >> "$PROP_FILE"
                }
                set_prop persist.waydroid.width 1600
                set_prop persist.waydroid.height 900
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
