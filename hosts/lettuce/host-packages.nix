{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;

  programs = {
    # ping and traceroute
    mtr.enable = true;

    # mount cloud drives (rclone, sshfs)
    # fuse.userAllowOther = true;

    # save gtk/gnome user settings
    dconf.enable = true;

    # gpg/ssh
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  environment.systemPackages = with pkgs; [
    killall
    wget
  ];
}
