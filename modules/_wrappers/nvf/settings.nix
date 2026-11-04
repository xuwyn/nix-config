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
    lineNumberMode = "relNumber";
    preventJunkFiles = true;
    searchCase = "smart";

    globals = {
      mapleader = " ";
      maplocalleader = " ";
      direnv_cmd = lib.getExe pkgs.direnv;
    };

    extraPackages = with pkgs; [
      nodejs
      alejandra
      nixfmt
    ];

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

      -- drop default gr* maps so plain `gr` fires instantly
      for _, k in ipairs({ "grn", "grr", "gra", "gri", "grt", "grx" }) do
        pcall(vim.keymap.del, { "n", "x" }, k)
      end

      -- reload with direnv when opening file
      vim.api.nvim_create_autocmd("User", {
        pattern = "DirenvLoaded",
        callback = function()
          local langs = { c = true, cpp = true, go = true, rust = true, python = true }
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf)
              and vim.bo[buf].buftype == ""
              and langs[vim.bo[buf].filetype]
            then
              vim.api.nvim_exec_autocmds("FileType", { buffer = buf })
            end
          end
        end,
      })

      -- no inline diagnostics for lua
      local vt = vim.diagnostic.handlers.virtual_text
      vim.diagnostic.handlers.virtual_text = {
        show = function(ns, bufnr, diagnostics, opts)
          if vim.bo[bufnr].filetype == "lua" then return end
          vt.show(ns, bufnr, diagnostics, opts)
        end,
        hide = vt.hide,
      }

      -- absolute line numbers in insert mode, relative otherwise
      vim.api.nvim_create_autocmd("InsertEnter", {
        pattern = "*",
        command = "set number norelativenumber",
      })
      vim.api.nvim_create_autocmd("InsertLeave", {
        pattern = "*",
        command = "set number relativenumber",
      })

      -- change number colours based on catppuccin to be more visible
      local function number_hl()
        local c = require("catppuccin.palettes").get_palette()
        vim.api.nvim_set_hl(0, "LineNr", { fg = c.overlay2 })
        vim.api.nvim_set_hl(0, "LineNrAbove", { fg = c.overlay2 })
        vim.api.nvim_set_hl(0, "LineNrBelow", { fg = c.overlay2 })
        vim.api.nvim_set_hl(0, "CursorLineNr", { fg = c.lavender, bold = true })
      end
      number_hl()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = number_hl })

      -- set nix formatter: alejandra by default, override with NIX_FORMATTER or :NixFmt
      vim.g.nix_formatter = vim.env.NIX_FORMATTER or "alejandra"

      vim.api.nvim_create_user_command("NixFmt", function(opts)
        if opts.args ~= "" then vim.g.nix_formatter = opts.args end
        vim.notify("nix formatter: " .. vim.g.nix_formatter)
      end, {
        nargs = "?",
        complete = function() return { "alejandra", "nixfmt" } end,
      })

      vim.api.nvim_create_user_command("UseNixfmt", function()
        vim.g.nix_formatter = "nixfmt"
        vim.notify("nix formatter: nixfmt")
      end, {})

      vim.api.nvim_create_user_command("UseAlejandra", function()
        vim.g.nix_formatter = "alejandra"
        vim.notify("nix formatter: alejandra")
      end, {})
    '';

    formatter.conform-nvim = {
      enable = true;
      setupOpts.formatters_by_ft.nix = lib.generators.mkLuaInline ''
        function() return { vim.g.nix_formatter } end
      '';
    };

    lsp = {
      enable = true;
      mappings = {
        goToDefinition = "gd";
        goToDeclaration = "gD";
        listImplementations = "gi";
        listReferences = null;
        renameSymbol = "<leader>rn";
        codeAction = "<leader>ca";
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
      # python.enable = true;
      go.enable = true;

      yaml.enable = true;
      toml.enable = true;
      json.enable = true;
      lua.enable = true;

      html.enable = true;
      css.enable = true;
      typescript.enable = true;

      nix = {
        enable = true;
        format.enable = false; # choose at runtime
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
        setupOpts.sections.lualine_c = [
          (lib.generators.mkLuaInline ''{ "filename", path = 1 }'')
        ];
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
      gitsigns = {
        enable = true;
        mappings = {
          stageHunk = null;
          undoStageHunk = null;
          resetHunk = null;
          stageBuffer = null;
          resetBuffer = null;
          previewHunk = null;
          diffThis = null;
          diffProject = null;
          blameLine = null;
          toggleBlame = null;
          toggleDeleted = null;
          nextHunk = null;
          previousHunk = null;
        };
      };
    };

    filetree = {
      neo-tree = {
        enable = true;
      };
    };

    treesitter = {
      context.enable = false;
      autotagHtml = true;
    };

    binds = {
      whichKey = {
        enable = true;
        register."<leader>h" = null;
      };
      cheatsheet.enable = true;
    };

    telescope = {
      enable = true;
      mappings = {
        findFiles = "<leader>ff";
        liveGrep = "<leader>fg";
        buffers = "<leader>fb";
        lspReferences = "gr";
        lspDocumentSymbols = "<leader>fs";
        lspWorkspaceSymbols = "<leader>fS";
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
      multicursors.enable = false;
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
      todo-comments = {
        enable = true;
        mappings = {
          quickFix = null;
          telescope = null;
          trouble = null;
        };
      };
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
