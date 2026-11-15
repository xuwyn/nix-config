# Thanks iynaix again! <3
# source: https://github.com/iynaix/dotfiles/blob/c9b90614016155c2f41d756c43d096b39147b1ef/isos.nix
{
  inputs,
  lib,
  self,
  system,
  ...
}: let
  repo_url = "https://raw.githubusercontent.com/xuwyn/nix-config";
  mkIso = nixpkgs: isoPath:
    nixpkgs.lib.nixosSystem {
      inherit system;
      modules =
        [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/${isoPath}.nix"
          (
            {
              config,
              pkgs,
              ...
            }: {
              # add memtest to the boot menu
              boot.loader.grub.memtest86.enable = pkgs.stdenv.hostPlatform.isx86;
              isoImage.makeBiosBootable = pkgs.stdenv.hostPlatform.isx86;

              # disable zfs for 26.11 default (I dont use zfs anyway)
              boot.zfs.forceImportRoot = false;

              environment = {
                systemPackages =
                  [
                    (pkgs.writeShellApplication {
                      name = "xwnix-install";
                      runtimeInputs = [pkgs.curl];
                      text = ''
                        script=$(mktemp)
                        curl -fsSL ${repo_url}/main/scripts/install.sh -o "$script"
                        sh "$script"
                      '';
                    })
                    (pkgs.writeShellApplication {
                      name = "xwnix-recover";
                      runtimeInputs = [pkgs.curl];
                      text = ''
                        script=$(mktemp)
                        curl -fsSL ${repo_url}/main/scripts/recover.sh -o "$script"
                        sh "$script"
                      '';
                    })
                  ]
                  ++ (with self.wrapperModules.${system}; [
                    (nvf {})
                    (zsh {})
                    (ns {})
                    (tealdeer {})
                    (shop {})
                    (yazi {})
                  ]);

                variables = {
                  EDITOR = "nvim";
                  VISUAL = "nvim";
                  NIXPKGS_ALLOW_UNFREE = "1";
                };
              };

              # use nmtui instead of wpa_supplicant for minimal iso
              networking.wireless.enable = lib.mkForce false;
              networking.networkmanager.enable = true;

              # update greeting for iso to suggest networkmanager
              services.getty.helpLine = lib.mkForce (
                ''
                  The "nixos" and "root" accounts have empty passwords, but SSH password
                  login is disabled. SSH in as root with your key once the network is up.

                  No ethernet? Connect to wifi with `nmtui`, then find your IP with `ip -br a`.
                ''
                + lib.optionalString config.services.xserver.enable ''
                  Type `sudo systemctl start display-manager` to
                  start the graphical user interface.
                ''
              );

              # bye bye xterm
              services.xserver.excludePackages = [pkgs.xterm];

              # enable SSH in the boot process.
              services.openssh = {
                enable = true;
                # disable password auth
                settings = {
                  PasswordAuthentication = false;
                  KbdInteractiveAuthentication = false;
                };
              };
              systemd.services.sshd.wantedBy = lib.mkForce ["multi-user.target"];
              users.users.root.openssh.authorizedKeys.keyFiles = [
                ./modules/common/keys/openssh_key.pub
              ];

              # nix.conf
              nix = {
                package = pkgs.nixVersions.latest;
                settings =
                  {
                    experimental-features = [
                      "nix-command"
                      "flakes"
                      "pipe-operators"
                    ];
                  }
                  // import ./caches.nix;
              };
            }
          )
        ]
        ++ (lib.optional (lib.hasInfix "plasma" isoPath) {
          environment.systemPackages = with self.wrapperModules.${system}; [
            (firefox {})
            (kitty {})
          ];

          # use wrapped firefox
          programs.firefox.enable = false;

          # disable kwallet
          environment.etc."xdg/kwalletrc".text = ''
            [Wallet]
            Enabled=false
            First Use=false
          '';

          # set dark mode
          environment.etc."xdg/kdeglobals".text = ''
            [KDE]
            LookAndFeelPackage=org.kde.breezedark.desktop
          '';
        });
    };
in {
  kde-iso = mkIso inputs.nixpkgs-stable "installation-cd-graphical-calamares-plasma6";
  minimal-iso = mkIso inputs.nixpkgs-stable "installation-cd-minimal-combined";
  cosmic-iso = mkIso inputs.nixpkgs-stable "installation-cd-graphical-calamares-cosmic";
}
