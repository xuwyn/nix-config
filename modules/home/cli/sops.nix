{
  config,
  inputs,
  ...
}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];
  sops = {
    # Path to keys
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    # Encrypted file
    defaultSopsFile = ../sops/secrets.yaml;
    defaultSopsFormat = "yaml";

    # What to decrypt and where to put them
    secrets = {
      "private_ssh_key" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519";
        mode = "0600";
      };
      "public_ssh_key" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
        mode = "0644";
      };
    };
  };
}
