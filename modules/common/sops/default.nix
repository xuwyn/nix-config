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
      lib,
      users,
      host,
      config,
      ...
    }: {
      imports = [inputs.sops-nix.nixosModules.sops];
      environment = commonSopsEnv pkgs;
      sops =
        commonSopsSettings host
        // {
          secrets = lib.listToAttrs (map (u: {
              name = "${u}_password";
              value = {neededForUsers = true;};
            })
            (lib.filter (u: !(config.nixos.users.${u}.isDeployer or false)) users));
        };
    };

    darwin.sops = {
      inputs,
      pkgs,
      host,
      ...
    }: {
      imports = [inputs.sops-nix.darwinModules.sops];
      environment = commonSopsEnv pkgs;
      sops = commonSopsSettings host // {secrets = {};};
    };

    homeManager.sops = {
      config,
      inputs,
      pkgs,
      ...
    }: {
      imports = [inputs.sops-nix.homeManagerModules.sops];
      home.packages = with pkgs; [age sops];
      sops = {
        age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        defaultSopsFile = ./${config.home.username}.yaml;
        defaultSopsFormat = "yaml";
        secrets = {
          private_ssh_key = {};
          public_ssh_key = {};
        };
      };
    };
  };
}
