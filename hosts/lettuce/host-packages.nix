{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;

  programs = {
    # ping and traceroute
    mtr.enable = true;

    # mount cloud drives (rclone, sshfs)
    # fuse.userAllowOther = true;

    dconf.enable = true; # save gtk/gnome user settings
  };

  environment.systemPackages = with pkgs; [
    killall
    wget
  ];
}
