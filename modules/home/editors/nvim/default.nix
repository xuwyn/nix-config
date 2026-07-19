{
  modules.homeManager.editors = {
    inputs,
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.homeManager.editors.nixvim;
    matugenEnabled = config.programs.matugen.enable or false;
    bar = config.homeManager.desktop.bar or null;
    barThemes = {
      noctalia = ''
        require('matugen').setup()
      '';
      dms = ''
        vim.cmd.colorscheme("dms")
      '';
    };
  in {
    options.homeManager.editors.nixvim = {
      enable = lib.mkEnableOption "Enable nixvim";
      barThemeEnabled = lib.mkOption {
        type = lib.types.bool;
        default = config.homeManager.desktop.barThemeEnabled or false;
      };
    };

    imports = [inputs.nixvim.homeModules.nixvim];

    config = lib.mkIf cfg.enable (lib.mkMerge [
      (lib.mkIf (bar == "noctalia") {
        home.file.".config/nvim/lua/matugen-template.lua".source = ./noctalia-template.lua;
      })
      {
        programs.nixvim = {
          enable = true;
          nixpkgs.useGlobalPackages = true;
          viAlias = true;
          vimAlias = true;

          globals = {
            mapleader = " ";
            maplocalleader = " ";
          };

          # Core editor options
          opts = {
            number = true;
            relativenumber = false;
            shiftwidth = 2;
            tabstop = 2;
            expandtab = true;
            smartindent = true;
            wrap = false;
            swapfile = false;
            termguicolors = true;
            signcolumn = "yes";
            updatetime = 200;
            cursorline = true;
            spell = true;
            spelllang = ["en"];
            # Send all yanks/deletes to the system clipboard (Wayland/X11)
            clipboard = "unnamedplus";
          };

          colorschemes.catppuccin = {
            enable = !cfg.barThemeEnabled && !matugenEnabled;
            settings = {
              flavour = "mocha"; # "latte", "mocha", "frappe", "macchiato", "auto"
              transparent_background = true;
              integrations = {
                lualine = true;
                bufferline = true;
              };
            };
          };

          extraPlugins = with pkgs; [
            vimPlugins.base16-nvim
            (pkgs.vimUtils.buildVimPlugin {
              pname = "base46";
              version = pkgs.sources.base46.version;
              src = pkgs.sources.base46.src;
              doCheck = false;
            })
          ];

          plugins = {
            # UI and visuals
            web-devicons.enable = false;
            lualine = {
              enable = true;
              settings = {
                options = {theme = "auto";};
              };
            };
            bufferline = {
              enable = false;
              settings = {
                options = {
                  show_tab_indicators = false;
                  show_close_icon = false;
                };
              };
            };
            indent-blankline.enable = true;
            colorizer.enable = true;
            illuminate.enable = true;

            # Save last session
            persistence.enable = true;

            # File tree (Neo-tree to match NVF)
            neo-tree = {
              enable = true;
            };

            # Fuzzy finder
            telescope.enable = true;

            # Treesitter for syntax/TS features
            treesitter.enable = true;
            treesitter-context.enable = false;

            # Project management
            project-nvim = {
              enable = true;
              settings = {
                history.save_dir = "${config.home.homeDirectory}/.local/share/nvim/project_nvim";
              };
            };

            # Notifications and UI polish
            notify.enable = true;
            noice.enable = false;

            # Startup dashboard
            alpha = {
              enable = true;
              theme = "dashboard"; # required by nixvim: either set a theme or a custom layout
            };

            # Git integrations
            gitsigns.enable = true;
            diffview.enable = true;

            # Motions and editing helpers
            hop.enable = true;
            leap.enable = true;
            vim-surround.enable = true;
            comment.enable = true;
            which-key.enable = true;

            # Autopairs for (), {}, [], '', "", etc.
            nvim-autopairs = {
              enable = true;
              settings = {
                check_ts = true; # leverage Treesitter for smarter pairing
                enable_check_bracket_line = false;
                fast_wrap = {
                  enable = true;
                  map = "<M-e>"; # Alt+e to fast-wrap
                  chars = ["{" "[" "(" "\"" "'" "`"];
                };
              };
            };

            # Terminal
            toggleterm = {
              enable = true;
              settings = {direction = "float";};
            };

            # Diagnostics UI
            trouble.enable = true;

            # Markdown preview
            markdown-preview.enable = true;

            # Completion and snippets
            blink-cmp = {
              enable = true;
              settings = {
                keymap = {
                  preset = "default";
                  "<CR>" = ["accept" "fallback"];
                  "<Tab>" = ["select_next" "fallback"];
                  "<S-Tab>" = ["select_prev" "fallback"];
                };
                appearance = {
                  nerd_font_variant = "mono";
                };
                completion = {
                  documentation = {
                    auto_show = true;
                    auto_show_delay_ms = 500;
                  };
                };
                sources = {
                  default = ["lsp" "path" "snippets" "buffer"];
                };
                snippets = {
                  preset = "luasnip";
                };
                fuzzy = {
                  implementation = "prefer_rust_with_warning";
                };
                signature = {
                  enabled = true;
                };
              };
            };

            luasnip.enable = true;
            friendly-snippets.enable = true;

            # Signature help while typing function params
            lsp-signature.enable = true;

            # LSP configuration
            lsp = {
              enable = true;
              servers = {
                nil_ls.enable = true;
                lua_ls.enable = true;
                pyright.enable = true;
                ts_ls.enable = true;
                html.enable = true;
                cssls.enable = true;
                clangd.enable = true;
                zls.enable = false;
                marksman.enable = false;
                hyprls.enable = !pkgs.stdenv.hostPlatform.isDarwin;
                # hyprls is optional; keep tools available via extraPackages
              };
              keymaps = {
                diagnostic = {
                  "<leader>dl" = "open_float";
                  "[d" = "goto_prev";
                  "]d" = "goto_next";
                };
              };
            };

            # Formatter: conform.nvim (Prettierd, Stylua, etc.)
            conform-nvim = {
              enable = true;
              settings = {
                formatters_by_ft = {
                  nix = ["alejandra"];
                  lua = ["stylua"];
                  javascript = ["prettierd"];
                  typescript = ["prettierd"];
                  javascriptreact = ["prettierd"];
                  typescriptreact = ["prettierd"];
                  css = ["prettierd"];
                  html = ["prettierd"];
                  markdown = ["prettierd"];
                  sh = ["shfmt"];
                };
                format_on_save = {
                  lsp_fallback = true;
                };
              };
            };
          };

          keymaps = [
            # Insert-mode escape
            {
              key = "jk";
              mode = ["i"];
              action = "<ESC>";
              options.desc = "Exit insert mode";
            }

            # Telescope
            {
              key = "<leader>ff";
              mode = ["n"];
              action = "<cmd>Telescope find_files<cr>";
              options.desc = "Search files by name";
            }
            {
              key = "<leader>lg";
              mode = ["n"];
              action = "<cmd>Telescope live_grep<cr>";
              options.desc = "Search files by contents";
            }

            # File tree (Neo-tree)
            {
              key = "<leader>fe";
              mode = ["n"];
              action = "<cmd>Neotree toggle<cr>";
              options.desc = "File browser toggle";
            }

            # Open last session
            {
              mode = "n";
              key = "<leader>sl";
              action.__raw = ''
                function()
                  require("persistence").load({ last = true })
                end
              '';
              options.desc = "Restore last session";
            }

            # Terminal
            {
              key = "<leader>t";
              mode = ["n"];
              action = "<cmd>ToggleTerm<CR>";
              options.desc = "Toggle terminal";
            }

            # Comment line (Doom Emacs style)
            {
              key = "<leader>.";
              mode = ["n"];
              action = "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>";
              options.desc = "Comment line";
            }
            {
              key = "<leader>.";
              mode = ["v"];
              action = "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>";
              options.desc = "Comment selection";
            }

            # Diagnostics
            {
              key = "<leader>dj";
              mode = ["n"];
              action = "<cmd>lua vim.diagnostic.goto_next()<CR>";
              options.desc = "Go to next diagnostic";
            }
            {
              key = "<leader>dk";
              mode = ["n"];
              action = "<cmd>lua vim.diagnostic.goto_prev()<CR>";
              options.desc = "Go to previous diagnostic";
            }
            {
              key = "<leader>dl";
              mode = ["n"];
              action = "<cmd>lua vim.diagnostic.open_float()<CR>";
              options.desc = "Show diagnostic details";
            }
            {
              key = "<leader>dt";
              mode = ["n"];
              action = "<cmd>Trouble diagnostics toggle<cr>";
              options.desc = "Toggle diagnostics list";
            }

            # Disable accidental F1 across modes
            {
              key = "<F1>";
              mode = ["n" "i" "v" "x" "s" "o" "t" "c"];
              action = "<Nop>";
              options.desc = "Disable accidental F1 help";
            }
            # Help mappings
            {
              key = "<leader>h";
              mode = ["n"];
              action = ":help<Space>";
              options = {
                desc = "Open :help prompt";
                nowait = true;
              };
            }
            {
              key = "<leader>H";
              mode = ["n"];
              action = ":help <C-r><C-w><CR>";
              options.desc = "Help for word under cursor";
            }
          ];

          # Runtime tools and language servers
          extraPackages = with pkgs;
            [
              ripgrep
              fd
              bat
              lazygit
              nil
              typescript-language-server
              typescript
              vscode-langservers-extracted
              pyright
              lua-language-server
              zls
              marksman
              multimarkdown
              clang-tools
              prettierd
              stylua
              shfmt
              nixpkgs-fmt
              alejandra
              figlet
              toilet
              bash-language-server
              tailwindcss-language-server
            ]
            ++ (
              if !pkgs.stdenv.hostPlatform.isDarwin
              then [
                wl-clipboard
                hyprls
              ]
              else []
            );

          # Diagnostic UI and notify background tweaks
          extraConfigLua = ''
            ${
              if cfg.barThemeEnabled
              then (barThemes.${bar} or "")
              else if matugenEnabled
              then ''
                local matugen_path = vim.fn.stdpath("config") .. "/lua/matugen-colors.lua"
                local function apply_matugen_theme()
                  if vim.uv.fs_stat(matugen_path) then
                    local ok, err = pcall(dofile, matugen_path)
                    if not ok then
                      vim.notify("Failed to load matugen theme: " .. tostring(err), vim.log.levels.ERROR)
                      return
                    end
                  end
                end
                apply_matugen_theme()
                local signal = vim.uv.new_signal()
                signal:start('sigusr1', vim.schedule_wrap(function()
                  vim.defer_fn(apply_matugen_theme, 50)
                end))
              ''
              else ''''
            }
            -- Inline diagnostics (virtual text) similar to NVF virtual_lines
            vim.diagnostic.config({
              virtual_text = { prefix = "●", spacing = 2 },
              update_in_insert = true,
              severity_sort = true,
              underline = true,
              signs = true,
            })

            -- Basic LSP keymaps when LSP attaches
            local function lsp_on_attach(_, bufnr)
              local map = function(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
              end
              map('n', 'K', vim.lsp.buf.hover, 'Hover docs')
              map('n', 'gd', vim.lsp.buf.definition, 'Goto definition')
              map('n', 'gD', vim.lsp.buf.declaration, 'Goto declaration')
              map('n', 'gi', vim.lsp.buf.implementation, 'Goto implementation')
              map('n', 'gr', vim.lsp.buf.references, 'References')
              map('n', '<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
              map('n', '<leader>ca', vim.lsp.buf.code_action, 'Code action')
            end

            -- If nixvim exposes a hook, register it; otherwise set a global autocmd
            if vim.g.__nixvim_lsp_attached ~= true then
              vim.g.__nixvim_lsp_attached = true
              vim.api.nvim_create_autocmd('LspAttach', {
                callback = function(args)
                  local bufnr = args.buf
                  lsp_on_attach(nil, bufnr)
                end,
              })
            end

            -- Notify background color
            local ok, notify = pcall(require, 'notify')
            if ok then
              notify.setup({ background_colour = vim.g.base16_gui00 or "#1e1e2e" })
              vim.notify = notify
            end
          '';
        };

        home.activation.projectNvimHistory = ''
          mkdir -p "$HOME/.local/share/nvim/project_nvim"
          find "$HOME/.local/share/nvim/project_nvim" -type f -size 0 -delete 2>/dev/null || true
        '';
      }
    ]);
  };
}
