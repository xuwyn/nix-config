{
  target = "lettuce";
  module = {
    self,
    pkgs,
    lib,
    system,
    ...
  }: let
    wm = self.wrapperModules.${system};
  in {
    environment.systemPackages = with wm; [
      (bottom {})
      (yazi {})
      (nvf {})
    ];

    custom = {
      binfmt.enable = false;
      nix-ld.enable = false;
      preservation.enable = false;
      scheduler.enable = false;
      printing.enable = false;
      yubikey.enable = false;
      zram.enable = false;

      ssh.hosts = {
        apricot = {};
        puffin = {};
        "apricot.local" = {};
        "puffin.local" = {};
      };
    };
  };
}
