{
  modules.nixos.drivers = {
    lib,
    pkgs,
    config,
    ...
  }:
    with lib; let
      cfg = config.nixos.drivers.amdgpu;
    in {
      options.nixos.drivers.amdgpu = {
        enable = mkEnableOption "Enable AMD GPU driver";
      };

      config = mkIf cfg.enable {
        systemd.tmpfiles.rules = ["L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"];
        services.xserver.videoDrivers = ["amdgpu"];
        nixpkgs.config.rocmSupport = true;
      };
    };
}
