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
      # TODO: write a script for this?
      # $ sudo rm -rf /var/lib/waydroid /home/.waydroid ~/waydroid ~/.share/waydroid ~/.local/share/waydroid ~/.local/share/applications/*waydroid*
      # $ sudo waydroid init -s GAPPS -f
      # $ echo 'ANDROID_RUNTIME_ROOT=/apex/com.android.runtime sqlite3 /data/data/com.google.android.gsf/databases/gservices.db "select * from main where name = \"android_id\";"' | sudo waydroid shell
      config = mkIf cfg.enable {
        virtualisation.waydroid = {
          enable = true;
          package = pkgs.waydroid-nftables;
        };

        services.geoclue2.enable = true;

        environment.systemPackages = let
          # nixpkgs bump finally makes this version of python obsolete 😢 (2026-08-31)
          waydroidScriptSrc = pkgs.fetchFromGitHub {
            owner = "AtaraxiaSjel";
            repo = "nur";
            rev = "f57371a89a5ab6d969de035af7b6d814f07b06b1";
            hash = "sha256-lunhMluFR5vUgZzwxuGeN0gIOYIwW2SPmaJzSC6A+Ys=";
          };
          waydroid-script = pkgs.python313Packages.callPackage "${waydroidScriptSrc}/pkgs/waydroid-script" {};
        in [
          pkgs.android-tools # adb
          pkgs.wl-clipboard
          pkgs.waydroid-helper
          waydroid-script
          (pkgs.writeShellApplication {
            name = "waydroid-fix-adb-auth";
            runtimeInputs = with pkgs; [android-tools waydroid-nftables];
            text = ''
              containerAdbKeys=/data/misc/adb/adb_keys
              hostPubkey="$HOME/.android/adbkey.pub"
              wd="sudo ${pkgs.waydroid-nftables}/bin/waydroid"

              if [ ! -f "$hostPubkey" ]; then
                echo "no host adb key found, generating..."
                adb keygen "$HOME/.android/adbkey"
              fi

              pubkey="$(cat "$hostPubkey")"
              existing="$($wd shell -- cat "$containerAdbKeys" 2>/dev/null || true)"

              if echo "$existing" | grep -qF "$pubkey"; then
                echo "key already authorized, nothing to do"
                exit 0
              fi

              echo "authorizing host key in waydroid container..."
              $wd shell -- mkdir -p "$(dirname "$containerAdbKeys")"
              echo "$pubkey" | $wd shell -- sh -c "cat >> $containerAdbKeys"
              $wd shell -- chmod 640 "$containerAdbKeys"
              $wd shell -- chown system:shell "$containerAdbKeys"

              echo "restarting waydroid..."
              $wd session stop
              sleep 3
              sudo systemctl restart waydroid-container
              sleep 1

              echo "done, run 'adb connect <waydroid-ip>:5555' to verify"
            '';
          })
        ];

        systemd = {
          packages = [pkgs.waydroid-helper];
          services.waydroid-mount.wantedBy = ["multi-user.target"];
        };
      };
    };
}
