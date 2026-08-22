{
  modules.darwin.linux-builder = {
    config,
    lib,
    pkgs,
    inputs,
    ...
  }: let
    # See: https://ryantm.github.io/nixpkgs/packages/darwin-builder/
    linuxSystem = builtins.replaceStrings ["darwin"] ["linux"] pkgs.stdenv.hostPlatform.system;
    darwin-builder = inputs.nixpkgs.lib.nixosSystem {
      system = linuxSystem;
      modules = [
        "${inputs.nixpkgs}/nixos/modules/profiles/nix-builder-vm.nix"
        {
          virtualisation = {
            host.pkgs = pkgs;
            darwin-builder.workingDirectory = "/var/lib/darwin-builder";
            darwin-builder.hostPort = 22;
          };
        }
      ];
    };
  in {
    nix.distributedBuilds = true;
    nix.buildMachines = [
      {
        hostName = "localhost";
        sshUser = "builder";
        sshKey = "/etc/nix/builder_ed25519";
        system = linuxSystem;
        maxJobs = 4;
        supportedFeatures = ["kvm" "benchmark" "big-parallel"];
      }
    ];
    launchd.daemons.darwin-builder = {
      command = "${darwin-builder.config.system.build.macos-builder-installer}/bin/create-builder";
      serviceConfig = {
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "/var/log/darwin-builder.log";
        StandardErrorPath = "/var/log/darwin-builder.log";
      };
    };
  };
}
