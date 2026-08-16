{
  modules = let
    commonNixSettings = {
      lib,
      config,
      ...
    }: {
      sops = {
        secrets = {
          github_token.sopsFile = ./sops/access-tokens.yaml;
          gitlab_token.sopsFile = ./sops/access-tokens.yaml;
          codeberg_token.sopsFile = ./sops/access-tokens.yaml;
        };
        templates."nix-access-tokens.conf".content = ''
          access-tokens = github.com=${config.sops.placeholder.github_token} gitlab.com=PAT:${config.sops.placeholder.gitlab_token} codeberg.org=${config.sops.placeholder.codeberg_token}
        '';
      };
      nix = {
        settings.experimental-features = [
          "nix-command"
          "flakes"
        ];
        extraOptions = lib.optionalString (config ? sops && config.sops.templates ? "nix-access-tokens.conf") ''
          !include ${config.sops.templates."nix-access-tokens.conf".path}
        '';
      };
    };
  in {
    nixos.nix-settings = {users, ...}: {
      imports = [commonNixSettings];
      nix.settings = {
        download-buffer-size = 200000000;
        auto-optimise-store = true;
        allowed-users = users;
        trusted-users = users;
      };
    };

    darwin.nix-settings = {users, ...}: {
      imports = [commonNixSettings];
      nix = {
        settings = {
          auto-optimise-store = true;
          allowed-users = users;
          trusted-users = users;
        };
      };
    };

    homeManager.nix-settings = {pkgs, ...}: {
      nix.package = pkgs.nix;
      imports = [commonNixSettings];
    };
  };
}
