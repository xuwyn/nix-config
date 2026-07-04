{
  flake.modules.homeManager.syncthing = {
    username,
    config,
    lib,
    pkgs,
    ...
  }: {
    services.syncthing = {
      enable = true;
      guiCredentials = {
        username = username;
        passwordFile = config.sops.secrets.syncthing_password.path;
      };
      guiAddress = "https://127.0.0.1:8384";
      overrideFolders = true;
      settings = {
        urAccepted = -1; # do not submit anonymous usage data
        folders = {
          "Shared" = {
            id = "e4820aa7e79671fc";
            label = "Shared";
            path = "${config.home.homeDirectory}/Shared";
            ignorePerms = true;
          };
        };
      };
    };
  };
}
