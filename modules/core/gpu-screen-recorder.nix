{pkgs, ...}: {
  programs.gpu-screen-recorder = {
    enable = true;
    package = pkgs.gpu-screen-recorder;
  };
}
