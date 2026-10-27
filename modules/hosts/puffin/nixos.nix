{
  targets = ["puffin"];
  module = {
    self,
    pkgs,
    lib,
    system,
    ...
  }: {
    # overlays to disable check for pkgs with no cache
    nixpkgs.overlays = [
      (final: prev: {
        pythonPackagesExtensions =
          prev.pythonPackagesExtensions
          ++ [
            (pyFinal: pyPrev: let
              noCheck = [
                "rich"
                "rich-argparse"
                "remarshal"
                "markdown-it-py"
                "pytest-regressions"
                "matplotlib"
                "pillow"
              ];
            in
              builtins.listToAttrs (map (name: {
                  inherit name;
                  value = pyPrev.${name}.overridePythonAttrs {doCheck = false;};
                })
                noCheck))
          ];
      })
    ];

    # Set avahi.publish here due to options deprecation in unstable (2026-10-24)
    services.avahi.publish = {
      enable = true;
      addresses = true;
    };

    # micro sd card disk layout
    fileSystems = {
      "/boot/firmware" = {
        device = "/dev/disk/by-label/FIRMWARE";
        fsType = "vfat";
        options = [
          "noatime"
          "noauto"
          "x-systemd.automount"
          "x-systemd.idle-timeout=1min"
        ];
      };
      "/" = {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
        options = ["noatime"];
      };
    };

    custom = {
      git.enable = false;
      binfmt.enable = false;
      nix-ld.enable = false;
      preservation.enable = false;
      scheduler.enable = false;
      printing.enable = false;
      yubikey.enable = false;

      ssh.hosts = {
        apricot = {};
        mango = {};
        capybara = {};
        lettuce = {};
        "apricot.local" = {};
        "mango.local" = {};
        "capybara.local" = {};
        "lettuce.local" = {};
      };

      atticd.device = "/dev/disk/by-label/cache";
    };
  };
}
