{
  flake.modules.nixos.thunar = {pkgs, ...}: {
    programs.thunar = {
      enable = true;
      plugins = [
        pkgs.thunar-archive-plugin
        pkgs.thunar-volman
      ];
    };
    environment.systemPackages = with pkgs; [
      ffmpegthumbnailer # Need For Video / Image Preview
    ];
  };
}
