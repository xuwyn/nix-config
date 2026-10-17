{
  platforms = ["linux"];
  module = {
    config,
    lib,
    pkgs,
    inputs,
    system,
    ...
  }: {
    options.custom.yubikey.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable yubikey support for sops-nix secrets";
    };

    config = lib.mkIf config.custom.yubikey.enable {
      # Read: https://themaxmur.github.io/RS-Key/linux.html#nixos-declarative
      environment.systemPackages = with pkgs; [
        yubikey-manager # ykman
        libfido2 # fido2-token, fido2-assert
        opensc # opensc-tool -l, pkcs11
        pcsc-tools # pcsc_scan
        age-plugin-yubikey # age in yubikey format
      ];

      services.pcscd.enable = true;

      # Let a non-root user (e.g. over SSH) talk to pcscd. Without this, CCID works
      # only as root and `ykman`/`gpg --card-status` fail from an SSH session.
      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          if ((action.id == "org.debian.pcsc-lite.access_pcsc" ||
               action.id == "org.debian.pcsc-lite.access_card") &&
              subject.isInGroup("wheel")) {
            return polkit.Result.YES;
          }
        });
      '';

      # Yubikey is used as key for sops-nix's user secrets
      # needs a systemd service to restart sops-nix decryption if key is detected
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", \
          ENV{ID_VENDOR_ID}=="1050", ENV{ID_SMARTCARD_READER}=="1", \
          TAG+="systemd", ENV{SYSTEMD_WANTS}+="sops-yubikey.service"
      '';

      systemd.services.sops-yubikey = {
        description = "Decrypt sops secrets when a YubiKey is plugged in";
        wants = ["pcscd.service"];
        after = ["pcscd.service"];
        serviceConfig = {
          Type = "oneshot";
          ExecStartPre = "${pkgs.coreutils}/bin/sleep 2"; # let pcscd enumerate the card
          ExecStart = "${config.systemd.package}/bin/systemctl restart sops-install-secrets.service";
        };
      };
    };
  };
}
