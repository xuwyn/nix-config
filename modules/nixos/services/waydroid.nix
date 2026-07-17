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
            after = ["waydroid-container.service"];
            bindsTo = ["waydroid-container.service"];
            wantedBy = ["multi-user.target"];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
              ExecStart = pkgs.writeShellScript "waydroid-fix" ''
                set -e
                ${pkgs.coreutils}/bin/sleep 5

                # fixes for nvidia gpu
                ${config.virtualisation.waydroid.package}/bin/waydroid prop set ro.hardware.gralloc default
                ${config.virtualisation.waydroid.package}/bin/waydroid prop set ro.hardware.egl swiftshader

                # set persist resolution
                ${config.virtualisation.waydroid.package}/bin/waydroid prop set persist.waydroid.density 240
                ${config.virtualisation.waydroid.package}/bin/waydroid prop set persist.waydroid.width 1600
                ${config.virtualisation.waydroid.package}/bin/waydroid prop set persist.waydroid.height 900
              '';
            };
          };
        };
      };
    };
}
