{
  modules = let
    commonSopsEnv = pkgs: {
      systemPackages = with pkgs; [ssh-to-age age sops];
      variables.SOPS_AGE_KEY_CMD = "ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key";
    };

    commonSopsSettings = host: {
      age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      defaultSopsFile = ./${host}.yaml;
      defaultSopsFormat = "yaml";
    };
  in {
    nixos.sops = {
      inputs,
      pkgs,
      host,
      ...
    }: {
      imports = [inputs.sops-nix.nixosModules.sops];
      environment = commonSopsEnv pkgs;
      sops = commonSopsSettings host;
    };

    darwin.sops = {
      inputs,
      pkgs,
      host,
      ...
    }: {
      imports = [inputs.sops-nix.darwinModules.sops];
      environment = commonSopsEnv pkgs;
      sops = commonSopsSettings host;
      # remove home's sops-nix decrypted secrets on log out
      # once secrets are decrypted in a login session, they stay there until a reboot
      launchd.user.agents.hm-secrets-cleanup = {
        serviceConfig = {
          ProgramArguments = [
            "/bin/sh"
            "-c"
            ''
              trap 'rm -rf "$(getconf DARWIN_USER_TEMP_DIR)secrets.d" "$HOME/.config/sops-nix/secrets"' TERM EXIT
              tail -f /dev/null &
              wait $!
            ''
          ];
          KeepAlive = true;
          RunAtLoad = true;
        };
      };
    };

    homeManager.sops = {
      config,
      inputs,
      pkgs,
      ...
    }: {
      imports = [inputs.sops-nix.homeManagerModules.sops];
      home.packages = with pkgs; [age sops age-plugin-yubikey];
      sops = {
        age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        age.plugins = [pkgs.age-plugin-yubikey];
        defaultSopsFile = ./${config.home.username}.yaml;
        defaultSopsFormat = "yaml";
        secrets = {
          private_ssh_key.sopsFile = ./ssh.yaml;
          public_ssh_key.sopsFile = ./ssh.yaml;
        };
      };
    };
  };
}
