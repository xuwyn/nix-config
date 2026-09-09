{
  modules.nixos.rs-key = {
    config,
    lib,
    pkgs,
    inputs,
    ...
  }: {
    # Read: https://themaxmur.github.io/RS-Key/linux.html#nixos-declarative
    environment.systemPackages = with pkgs; [
      yubikey-manager # ykman
      libfido2 # fido2-token, fido2-assert
      opensc # opensc-tool -l, pkcs11
      pcsc-tools # pcsc_scan
      age-plugin-yubikey # age in yubikey format
    ];

    # PC/SC daemon for the CCID applets (OpenPGP / PIV / OATH / OTP).
    services.pcscd = {
      enable = true;
      plugins = lib.mkForce [
        inputs.rs-key.packages.${pkgs.stdenv.hostPlatform.system}.ccid-rs-key
      ];
    };

    # udev rules that grant access to the FIDO hidraw node. The stock yubico
    # rules match VID 0x1050 only, so the default RS-Key identity (0x1209) needs
    # its own rule; build VIDPID=Yubikey5 instead if you want to reuse the stock
    # yubico rules unchanged.
    services.udev.packages = [
      pkgs.yubikey-personalization
      pkgs.libfido2
    ];
    services.udev.extraRules = ''
      # RS-Key own identity (pid.codes 0x1209:0x0001) — FIDO HID + CCID access.
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="0001", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="0001", TAG+="uaccess"
    '';

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
  };
}
