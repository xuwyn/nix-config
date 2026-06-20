{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;

  programs = {
    # ping and traceroute
    mtr.enable = true;

    # mount cloud drives (rclone, sshfs)
    # fuse.userAllowOther = true;
  };

  environment.systemPackages = with pkgs; [
    killall
    wget
  ];
}
