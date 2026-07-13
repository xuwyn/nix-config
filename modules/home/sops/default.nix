{
  modules.homeManager.sops = {
    config,
    inputs,
    pkgs,
    ...
  }: {
    imports = [inputs.sops-nix.homeManagerModules.sops];
    home.packages = with pkgs; [
      age # sops key
      sops
    ];
    sops = {
      # Path to keys
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

      # Encrypted file
      defaultSopsFile = ./secrets.yaml;
      defaultSopsFormat = "yaml";

      # What to decrypt and where to put them
      secrets = {
        "private_ssh_key" = {};
        "public_ssh_key" = {};
        "syncthing_password" = {};
        "github_token" = {};
      };

      # templates for files containing decrypted secrets
      templates = {
        "nix-access-tokens.conf".content = ''
          access-tokens = github.com=${config.sops.placeholder.github_token}
        '';
      };
    };
  };
}
