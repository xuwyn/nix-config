{
  flake.modules.homeManager.zed = {
    config,
    pkgs,
    ...
  }: {
    home.sessionVariables = {
      ZED_ALLOW_EMULATED_GPU = "1"; # for WSL
    };

    programs.zed-editor = {
      enable = true;
      extensions = [
        "nix"
        "yaml"
        "toml"
        "lua"
      ];

      userSettings = {
        lsp.nil = {
          binary.path = "${pkgs.nil}/bin/nil";
          settings.diagnostics.ignored = [];
        };
        languages.Nix = {
          language_servers = ["nil" "!nixd"];
          format_on_save = "on";
          formatter.external = {
            command = "${pkgs.alejandra}/bin/alejandra";
            arguments = ["--quiet" "--"];
          };
        };
        theme = "Vortriz";
      };
      themes.custom = import ./_theme.nix {inherit config;};
    };
  };
}
