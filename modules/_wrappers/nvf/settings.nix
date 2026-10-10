# read: https://nvf.notashelf.dev/configuring.html
# example: https://github.com/NotAShelf/nvf/blob/main/configuration.nix
# example: https://github.com/iynaix/dotfiles/blob/main/modules/shell/neovim/_settings.nix
{
  lib,
  pkgs,
  ...
}: {
  config.vim = {
    viAlias = true;
    vimAlias = true;
    lineNumberMode = "number";
    preventJunkFiles = true;
    searchCase = "smart";

    globals = {
      mapleader = " ";
      maplocalleader = " ";
      direnv_cmd = lib.getExe pkgs.direnv;
    };

    extraPackages = with pkgs; [nodejs];

    extraPlugins = with pkgs.vimPlugins; {
      direnv = {
        package = direnv-vim;
      };
    };

    options = {
      cursorline = true;
      gdefault = true; # replace all by default
      magic = true;
      exrc = true; # use project specific vimrc
      smartindent = true;
      virtualedit = "block"; # allow cursor to move anywhere in visual block mode
      tabstop = 2;
      softtabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      shiftround = true; # round indent to multiple of 'shiftwidth' for > and < command
    };

    clipboard = {
      enable = true;
      registers = "unnamedplus";
    };

    spellcheck = {
      enable = true;
      programmingWordlist.enable = true;
    };

    diagnostics = {
      enable = true;
      config = {
        virtual_text = true;
        severity_sort = true;
      };
    };

    luaConfigPost = ''
      -- remove trailing whitespace on save
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*",
        command = "silent! %s/\\s\\+$//e",
      })

      -- save on focus lost
      vim.api.nvim_create_autocmd("FocusLost", { pattern = "*",
        command = "silent! wa",
      })
    '';

    lsp = {
      enable = true;
      mappings = {
        goToDefinition = "gd";
        goToDeclaration = "gD";
        listImplementations = "gi";
        listReferences = null;
        renameSymbol = "rn";
        codeAction = "ca";
      };
      formatOnSave = true;
      lspkind.enable = false; # redundant with blink
      lightbulb.enable = false;
      lspsaga.enable = false;
      trouble.enable = true;
      lspSignature.enable = false; # conflicts with blink
      otter-nvim.enable = true;
      nvim-docs-view.enable = false;
      presets.harper.enable = false;
      servers.rust-analyzer = {
        settings.rust-analyzer = {
          check = {
            command = "clippy";
          };
        };
      };
    };

    languages = {
      enableFormat = true;
      enableTreesitter = true;

      bash.enable = true;
      zsh.enable = true;
      env.enable = true;
      just.enable = true;

      clang.enable = true;
      cmake.enable = true;
      make.enable = true;
      vhdl.enable = true;
      arduino.enable = true;
      assembly.enable = true;
      python.enable = true;

      yaml.enable = true;
      toml.enable = true;
      json.enable = true;
      lua.enable = true;

      html.enable = true;
      css.enable = true;
      typescript.enable = true;

      nix = {
        enable = true;
        format = {
          enable = true;
          type = ["alejandra"];
        };
        lsp.servers = ["nil"];
      };
      rust = {
        enable = true;
        extensions.crates-nvim.enable = false;
      };
      markdown = {
        enable = true;
        extensions.render-markdown-nvim.enable = true;
      };
    };

    visuals = {
      nvim-scrollbar.enable = false;
      neoscroll-nvim.enable = false;
      twilight-nvim.enable = false;
      satellite-nvim.enable = false;
      nvim-web-devicons.enable = true;
      nvim-cursorline.enable = true;
      cinnamon-nvim.enable = true;
      fidget-nvim.enable = true;
      highlight-undo.enable = true;
      blink-indent.enable = true;
      indent-blankline.enable = false;
      cellular-automaton.enable = false;
    };

    statusline = {
      lualine = {
        enable = true;
        integrations.breadcrumbs = {
          vanilla.enable = true;
          nvim-navic.enable = false;
          navbuddy.enable = false;
          lspsaga.enable = false;
        };
      };
    };

    autopairs.nvim-autopairs.enable = true;

    autocomplete = {
      nvim-cmp.enable = false;
      blink-cmp = {
        enable = true;
        setupOpts.signature.enabled = true;
      };
    };

    snippets.luasnip.enable = true;

    git = {
      enable = true;
      gitsigns.enable = true;
    };
    filetree = {
      neo-tree = {
        enable = true;
      };
    };

    treesitter = {
      context.enable = true;
      autotagHtml = true;
    };

    binds = {
      whichKey.enable = true;
      cheatsheet.enable = true;
    };

    telescope = {
      enable = true;
      mappings = {
        findFiles = "<leader>ff";
        liveGrep = "<leader>fg";
        buffers = "<leader>fb";
        lspReferences = "gr";
      };
    };

    dashboard = {
      dashboard-nvim.enable = false;
      alpha.enable = true;
    };

    notify = {
      nvim-notify.enable = true;
    };

    projects = {
      project-nvim.enable = true;
    };

    utility = {
      direnv.enable = true;
      diffview-nvim.enable = true;
      surround.enable = true;
      multicursors.enable = true;
      smart-splits.enable = true;
      undotree.enable = true;
      grug-far-nvim.enable = true;
      motion = {
        hop.enable = false;
        leap.enable = true;
      };
      images = {
        image-nvim.enable = false;
        img-clip.enable = true;
      };
      preview.markdownPreview.enable = true;
    };

    notes = {
      neorg.enable = false;
      orgmode.enable = false;
      todo-comments.enable = true;
    };

    terminal = {
      toggleterm = {
        enable = true;
        lazygit.enable = true;
        setupOpts = {
          direction = "float";
          float_opts.border = "curved";
        };
      };
    };

    ui = {
      borders.enable = true;
      noice.enable = true;
      colorizer.enable = true;
      illuminate.enable = true;
      fastaction.enable = true;
    };

    session = {
      nvim-session-manager.enable = false;
    };

    gestures = {
      gesture-nvim.enable = false;
    };

    comments = {
      comment-nvim.enable = true;
    };
  };
}
