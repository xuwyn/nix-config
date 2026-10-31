{
  flakeInputs,
  types,
  username,
  ...
} @ adios: {
  options = {
    extraSettings = {
      type = types.attrs;
      default = {};
    };
    extraKeymap = {
      type = types.attrs;
      default = {};
    };
    extraTheme = {
      type = types.attrs;
      default = {};
    };
    username = {
      type = types.string;
      default = username;
    };
    noctaliaThemeEnabled = {
      type = types.bool;
      default = false;
    };

    keymap.default = adios.promise ({options}: import ./keymap.nix // options.extraKeymap);

    settings.default = adios.promise ({options}:
      {
        log.enabled = true;
        mgr = {
          ratio = [1 2 3];
          sort_by = "alphabetical";
          sort_sensitive = false;
          sort_reverse = false;
          linemode = "size";
          show_hidden = true;
        };
        plugin.prepend_fetchers = [
          {
            url = "*";
            run = "git";
            group = "git";
          }
          {
            url = "*/";
            run = "git";
            group = "git";
          }
        ];
      }
      // options.extraSettings);

    plugins.default = adios.promise ({inputs}: let
      p = inputs.nixpkgs.pkgs.yaziPlugins;
    in {
      "full-border.yazi" = p.full-border;
      "git.yazi" = p.git;
      "smart-enter.yazi" = p.smart-enter;
      "smart-paste.yazi" = p.smart-paste;
      "yank-clipboard.yazi" = p.clipboard;
    });

    initLua.default = ''
      require("full-border"):setup ({ set = "rounded", })
      require("git"):setup()
      require("smart-enter"):setup { open_multi = true }
    '';

    theme.default = adios.promise ({options}:
      {
        flavor = let
          custom =
            if options.noctaliaThemeEnabled
            then "noctalia"
            else "catppuccin-mocha";
        in {
          dark = custom;
          light = custom;
        };
        mgr = {
          folder_offset = [1 0 1 0];
          preview_offset = [1 1 1 1];
        };
        status = {
          overall = {bold = true;};
          sep_left = ["░▒▓" "▓▒░"];
          sep_right = ["░▒▓" "▓▒░"];
        };
      }
      // options.extraTheme);

    flavors.default = adios.promise ({
      options,
      inputs,
    }:
      {
        "catppuccin-mocha.yazi" = "${flakeInputs.catppuccin-yazi}/catppuccin-mocha.yazi";
      }
      // inputs.nixpkgs.lib.optionalAttrs options.noctaliaThemeEnabled {
        "noctalia.yazi" = "/home/${options.username}/.config/yazi/flavors/noctalia.yazi";
      });
  };
}
