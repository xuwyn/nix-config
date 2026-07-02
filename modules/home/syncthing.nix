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
      overrideFolders = true;
      settings = {
        folders = {
          "shared-documents" = {
            id = "documents-sync-id";
            label = "Shared";
            path = "${config.home.homeDirectory}/Shared";
            devices = [];
            ignorePerms = true;
          };
        };
      };
    };
  };
}
