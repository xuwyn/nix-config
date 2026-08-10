{
  modules = let
    accessTokensFile = ./access-tokens.yaml;

    accessTokens = {
      github_token.sopsFile = accessTokensFile;
      gitlab_token.sopsFile = accessTokensFile;
      codeberg_token.sopsFile = accessTokensFile;
    };

    accessTokensTemplate = {config, ...}: {
      sops.templates."nix-access-tokens.conf".content = ''
        access-tokens = github.com=${config.sops.placeholder.github_token} gitlab.com=PAT:${config.sops.placeholder.gitlab_token} codeberg.org=${config.sops.placeholder.codeberg_token}
      '';
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
      imports = [inputs.sops-nix.nixosModules.sops accessTokensTemplate];
      environment = {
        systemPackages = with pkgs; [ssh-to-age age sops];
        variables.SOPS_AGE_KEY_CMD = "ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key";
      };
      sops = {
        age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
        defaultSopsFile = ./${host}.yaml;
        defaultSopsFormat = "yaml";
        secrets =
          lib.listToAttrs (map (u: {
              name = "${u}_password";
              value = {neededForUsers = true;};
            })
            (lib.filter (u: !(config.nixos.users.${u}.isDeployer or false)) users))
          // accessTokens;
      };
    };

    darwin.sops = {
      inputs,
      pkgs,
      host,
      ...
    }: {
      imports = [inputs.sops-nix.darwinModules.sops accessTokensTemplate];
      environment = {
        systemPackages = with pkgs; [ssh-to-age age sops];
        variables.SOPS_AGE_KEY_CMD = "ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key";
      };
      sops = {
        age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
        defaultSopsFile = ./${host}.yaml;
        defaultSopsFormat = "yaml";
        secrets = {} // accessTokens;
      };
    };

    homeManager.sops = {
      config,
      inputs,
      pkgs,
      ...
    }: {
      imports = [inputs.sops-nix.homeManagerModules.sops accessTokensTemplate];
      home.packages = with pkgs; [age sops];
      sops = {
        age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        defaultSopsFile = ./${config.home.username}.yaml;
        defaultSopsFormat = "yaml";
        secrets =
          {
            private_ssh_key = {};
            public_ssh_key = {};
          }
          // accessTokens;
      };
    };
  };
}
