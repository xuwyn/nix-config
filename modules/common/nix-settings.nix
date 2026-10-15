{
  config,
  users,
  ...
}: {
  sops = {
    secrets = {
      github_token.sopsFile = ./sops/access-tokens.yaml;
      gitlab_token.sopsFile = ./sops/access-tokens.yaml;
    };
    templates."nix-access-tokens.conf".content = ''
      access-tokens = github.com=${config.sops.placeholder.github_token} gitlab.com=PAT:${config.sops.placeholder.gitlab_token}
    '';
  };

  nix = {
    optimise.automatic = true;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];
      netrc-file = config.sops.templates.".netrc".path;
      allowed-users = users;
      trusted-users = users;
    };
    extraOptions = ''
      !include ${config.sops.templates."nix-access-tokens.conf".path}
    '';
  };
}
