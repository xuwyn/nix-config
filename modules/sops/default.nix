{
  modules.nixos.sops = {
    config,
    inputs,
    pkgs,
    lib,
    users,
    ...
  }: {
    imports = [inputs.sops-nix.nixosModules.sops];
    environment.systemPackages = with pkgs; [age sops];

    sops = {
      age.keyFile = "/etc/sops/age/keys.txt";

      defaultSopsFile = ./${config.networking.hostName}.yaml;
      defaultSopsFormat = "yaml";

      secrets = lib.listToAttrs (map (u: {
          name = "${u}_password";
          value = {neededForUsers = true;};
        })
        users);
    };
  };

  modules.homeManager.sops = {
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
        "private_ssh_key" = {};
        "public_ssh_key" = {};
        "syncthing_password" = {};
        "github_token" = {};
      };

      templates = {
        "nix-access-tokens.conf".content = ''
          access-tokens = github.com=${config.sops.placeholder.github_token}
        '';
      };
    };
  };
}
