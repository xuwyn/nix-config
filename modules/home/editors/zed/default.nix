{
  flake.modules.homeManager.zed = {
    config,
    pkgs,
    ...
  }: {
    home.sessionVariables = {
      ZED_ALLOW_EMULATED_GPU = "1";
    };

    home.packages = with pkgs; [
      lua-language-server
      stylua
    ];

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

        lsp.lua-language-server = {
          binary.path = "${pkgs.lua-language-server}/bin/lua-language-server";
          settings.Lua.diagnostics.disable = ["unused-local" "undefined-global" "lowercase-global"];
        };
        languages.Lua = {
          language_servers = ["lua-language-server" "..."];
          format_on_save = "on";
          formatter.external = {
            command = "${pkgs.stylua}/bin/stylua";
            arguments = [
              "--syntax=Lua54"
              "--respect-ignores"
              "--stdin-filepath"
              "{buffer_path}"
              "-"
            ];
          };
        };
        theme = "Vortriz";
      };
      themes.custom = import ./_theme.nix {inherit config;};
    };
  };
}
