{config, ...}: {
  darwin.apricot = {
    users = ["wyn" "deploy"];
    modules = with config.modules.darwin;
      [nix-settings system sops tailscale deploy users network]
      ++ [homebrew desktop attic]
      ++ [
        {
          darwin = {
            attic = {
              tailscaleDomain = "puffin.tail9fb2b9.ts.net";
              lanDomain = "puffin.local";
              cacheName = "apricot-darwin";
              publicKey = "91bXCDOh1EuPxl5Q8yKzSXsxeobBRc749rS5h9IkENw=";
            };
            users = {
              wyn.sshKeys = [../../common/keys/openssh_key.pub];
              deploy.sshKeys = [../../common/keys/deploy_key.pub];
            };
            desktop.omniwm.enable = true;
          };
        }
      ];
  };
}
