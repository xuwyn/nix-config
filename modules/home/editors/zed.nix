{
  modules.homeManager.editors = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.homeManager.editors.zed;
    matugenEnabled = config.programs.matugen.enable;
    bar = config.homeManager.desktop.bar or null;
    barThemes = {
      noctalia = "Noctalia Dark Transparent";
      dms = "DankShell Dark Transparent";
    };
  in {
    options.homeManager.editors.zed = {
      enable = lib.mkEnableOption "Enable zed-editor";
      barThemeEnabled = lib.mkOption {
        type = lib.types.bool;
        default = config.homeManager.desktop.barThemeEnabled or false;
      };
    };

    config = lib.mkIf cfg.enable {
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
          theme =
            if cfg.barThemeEnabled
            then barThemes.${bar}
            else if matugenEnabled
            then "Matugen Dark"
            else "Ayu Mirage";

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
        };
      };
    };
  };
}
