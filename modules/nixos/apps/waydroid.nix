{
  tags = ["desktop"];
  platforms = ["linux"];
  module = {
    config,
    lib,
    pkgs,
    inputs,
    ...
  }: {
    # see: https://github.com/pioner14/Waydroid_on_NixOS/blob/main/Waydroid_Setup_Guide.md
    # TODO: write a script for this?
    # $ sudo rm -rf /var/lib/waydroid /home/.waydroid ~/waydroid ~/.share/waydroid ~/.local/share/waydroid ~/.local/share/applications/*waydroid*
    # $ sudo waydroid init -s GAPPS -f
    # $ echo 'ANDROID_RUNTIME_ROOT=/apex/com.android.runtime sqlite3 /data/data/com.google.android.gsf/databases/gservices.db "select * from main where name = \"android_id\";"' | sudo waydroid shell
    config = lib.mkMerge [
      {
        virtualisation.waydroid = {
          enable = lib.mkDefault true;
          package = pkgs.waydroid-nftables;
        };
      }

      (lib.mkIf config.virtualisation.waydroid.enable {
        services.geoclue2.enable = true;
        environment.systemPackages = [
          pkgs.android-tools # adb
          pkgs.wl-clipboard
          pkgs.waydroid-helper
          (pkgs.callPackage "${inputs.waydroid-script}/package.nix" {})
        ];
        systemd = {
          packages = [pkgs.waydroid-helper];
          services.waydroid-mount.wantedBy = ["multi-user.target"];
        };
      })
    ];
  };
}
