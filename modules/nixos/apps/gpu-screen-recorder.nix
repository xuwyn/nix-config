{
  tags = ["desktop"];
  platforms = ["linux"];
  module = {
    pkgs,
    lib,
    ...
  }: {
    programs.gpu-screen-recorder = {
      enable = lib.mkDefault true;
      package = pkgs.gpu-screen-recorder;
    };
  };
}
