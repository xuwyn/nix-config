{
  types,
  flakeInputs,
  ...
} @ adios: {
  options = {
    package.default = adios.promise ({inputs}: inputs.nixpkgs.pkgs.evil-helix);
    extraSettings = {
      type = types.attrs;
      default = {};
    };
    extraLanguages = {
      type = types.attrs;
      default = {};
    };
    username = {
      type = types.string;
      default = "wyn";
    };
    noctaliaThemeEnabled = {
      type = types.bool;
      default = false;
    };

    themeDir.default = adios.promise ({
      options,
      inputs,
    }: let
      pkgs = inputs.nixpkgs.pkgs;
      mocha = builtins.fromTOML (builtins.readFile "${flakeInputs.catppuccin-helix}/themes/default/catppuccin_mocha.toml");
      transparent =
        (pkgs.formats.toml {}).generate "catppuccin_transparent.toml"
        (mocha // {"ui.background" = {};});
    in
      if options.noctaliaThemeEnabled
      then "/home/${options.username}/.config/helix/themes"
      else
        pkgs.linkFarm "helix-themes" [
          {
            name = "catppuccin_transparent.toml";
            path = transparent;
          }
        ]);

    settings.default = adios.promise ({options}:
      {
        theme =
          if options.noctaliaThemeEnabled
          then "noctalia"
          else "catppuccin_transparent";
        editor.evil = true;
        keys = {
          insert.j.k = "normal_mode";
          normal.space."." = "toggle_comments";
          select.space."." = "toggle_comments";
          normal.space.c = "no_op";
          normal.space.C = "no_op";
          select.space.c = "no_op";
          select.space.C = "no_op";
        };
      }
      // options.extraSettings);

    extraPackages.default = adios.promise ({inputs}:
      with inputs.nixpkgs.pkgs; [
        nil
        alejandra
        taplo
        lua-language-server
        stylua
        yaml-language-server
        prettier
        marksman
        clang-tools
        bash-language-server
        shellcheck
        shfmt
        basedpyright
        ruff
        rust-analyzer
        rustfmt
      ]);

    languages.default = adios.promise ({options}:
      {
        language = [
          {
            name = "nix";
            auto-format = true;
            formatter.command = "alejandra";
            language-servers = ["nil"];
          }
          {
            name = "lua";
            auto-format = true;
            formatter.command = "stylua";
            formatter.args = ["-"];
          }
          {
            name = "json";
            auto-format = true;
            formatter = {
              command = "prettier";
              args = ["--parser" "json"];
            };
          }
          {
            name = "python";
            auto-format = true;
            language-servers = ["basedpyright" "ruff"];
            formatter = {
              command = "ruff";
              args = ["format" "-"];
            };
          }
          {
            name = "bash";
            auto-format = true;
            formatter = {
              command = "shfmt";
              args = ["-i" "2"];
            };
          }
          {
            name = "jsonc";
            auto-format = true;
            formatter = {
              command = "prettier";
              args = ["--parser" "jsonc"];
            };
          }
          {
            name = "html";
            auto-format = true;
            formatter = {
              command = "prettier";
              args = ["--parser" "html"];
            };
          }
          {
            name = "rust";
            auto-format = true;
          }
          {
            name = "c";
            auto-format = true;
          }
          {
            name = "cpp";
            auto-format = true;
          }
        ];
      }
      // options.extraLanguages);
  };
}
