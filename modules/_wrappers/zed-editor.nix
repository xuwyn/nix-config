{types, ...} @ adios: {
  inputs.nixpkgs.from = {parent}: parent.nixpkgs;

  options = {
    noctaliaThemeEnabled = {
      type = types.bool;
      default = false;
    };
    extraSettings = {
      type = types.attrs;
      default = {};
    };
  };

  result = adios.promise ({
    options,
    inputs,
  }: let
    pkgs = inputs.nixpkgs.pkgs;
    lib = inputs.nixpkgs.lib;
    json = pkgs.formats.json {};

    base = {
      buffer_font_size = 10;
      ui_font_size = 12;
      theme =
        if options.noctaliaThemeEnabled
        then "Noctalia Dark Transparent"
        else "Ayu Mirage";

      auto_install_extensions = {
        nix = true;
        lua = true;
      };

      # c/cpp
      lsp.clangd.binary.path = "${pkgs.clang-tools}/bin/clangd";
      languages.C.format_on_save = "on";
      languages."C++".format_on_save = "on";

      # rust
      lsp.rust-analyzer.binary.path = "${pkgs.rust-analyzer}/bin/rust-analyzer";
      languages.Rust.format_on_save = "on";

      # nix
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

      # lua
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

    settingsFile = json.generate "zed-settings.json" (lib.recursiveUpdate base options.extraSettings);
  in
    pkgs.symlinkJoin {
      name = "zed-editor-wrapped";
      paths = [pkgs.zed-editor];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/zeditor \
          --set ZED_ALLOW_EMULATED_GPU 1 \
          --run 'cfg="''${XDG_CONFIG_HOME:-$HOME/.config}/zed"; mkdir -p "$cfg"; ln -sfT ${settingsFile} "$cfg/settings.json"'
      '';
    });
}
