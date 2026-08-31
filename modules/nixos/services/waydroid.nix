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
