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
                    inputs.nix-index-database.packages.${system}.comma-with-db
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

              # qol
              nixpkgs.config.allowUnfree = true;
              hardware.enableRedistributableFirmware = true;
              networking.networkmanager.enable = true;

              # old hardware compat -- comment these out on newer hardware
              boot.extraModulePackages = [config.boot.kernelPackages.broadcom_sta];
              boot.blacklistedKernelModules = ["b43" "bcma" "ssb"];
              nixpkgs.config.permittedInsecurePackages = ["broadcom-sta-6.30.223.271-59-${config.boot.kernelPackages.kernel.version}"];

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
              users.users = {
                root.openssh.authorizedKeys.keyFiles = [./modules/common/keys/openssh_key.pub];
                nixos.openssh.authorizedKeys.keyFiles = [./modules/common/keys/openssh_key.pub];
              };

              # nix.conf
              nix = {
                package = pkgs.nixVersions.latest;
                settings = let
                  caches = import ./caches.nix;
                in {
                  experimental-features = [
                    "nix-command"
                    "flakes"
                    "pipe-operators"
                  ];

                  extra-substituters =
                    lib.subtractLists [
                      "https://puffin.tail9fb2b9.ts.net/main"
                    ]
                    caches.extra-substituters;

                  extra-trusted-public-keys =
                    lib.subtractLists [
                      "main:AOInzGo25vK/CX+//GtecGc5zoePljsTyLki/rliiS8="
                    ]
                    caches.extra-trusted-public-keys;
                };
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
  minimal-iso = mkIso inputs.nixpkgs-stable "installation-cd-minimal"; # use `-combined` for latest kernel
  cosmic-iso = mkIso inputs.nixpkgs-stable "installation-cd-graphical-calamares-cosmic";
}
