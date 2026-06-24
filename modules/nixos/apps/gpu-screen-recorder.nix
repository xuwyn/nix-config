{
  flake.modules.nixos.gpu-screen-recorder = {pkgs, ...}: {
    programs.gpu-screen-recorder = {
      enable = true;
      package = pkgs.gpu-screen-recorder;
    };
  };
}
