let
  mkKeymap = mode: key: action: {inherit mode key action;};
  mkKeymapWithOpts = mode: key: action: opts:
    (mkKeymap mode key action) // opts;
in {
  vim = {
    keymaps = [
      # insert mode
      (mkKeymapWithOpts "i" "jk" "<ESC>" {desc = "Exit insert mode";})
      # telescope
      (mkKeymapWithOpts "n" "<leader>ff" "<cmd>Telescope find_files<CR>" {desc = "Find files";})
      (mkKeymapWithOpts "n" "<leader>fg" "<cmd>Telescope live_grep<CR>" {desc = "Grep all files";})
      (mkKeymapWithOpts "n" "<leader>fb" "<cmd>Telescope buffers<CR>" {desc = "Open buffers";})
      # file tree
      (mkKeymapWithOpts "n" "<leader>fe" "<cmd>Neotree toggle<CR>" {desc = "File browser toggle";})
      # terminal
      (mkKeymapWithOpts "n" "<leader>t" "<cmd>ToggleTerm<CR>" {desc = "Toggle terminal";})
      # comments
      (mkKeymapWithOpts "n" "<leader>." "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>" {desc = "Comment line";})
      (mkKeymapWithOpts "v" "<leader>." "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>" {desc = "Comment selection";})
      # diagnostics
      (mkKeymapWithOpts "n" "<leader>dj" "function() vim.diagnostic.jump({ count = 1 }) end" {
        lua = true;
        desc = "Go to next diagnostic";
      })
      (mkKeymapWithOpts "n" "<leader>dk" "function() vim.diagnostic.jump({ count = -1 }) end" {
        lua = true;
        desc = "Go to previous diagnostic";
      })
      (mkKeymapWithOpts "n" "<leader>dl" "<cmd>lua vim.diagnostic.open_float()<CR>" {desc = "Show diagnostic details";})
      (mkKeymapWithOpts "n" "<leader>dt" "<cmd>Trouble diagnostics toggle<CR>" {desc = "Toggle diagnostics list";})
      # disable accidental F1 across modes
      (mkKeymapWithOpts ["n" "i" "v" "x" "s" "o" "t" "c"] "<F1>" "<Nop>" {desc = "Disable accidental F1 help";})
      # help
      (mkKeymapWithOpts "n" "<leader>h" ":help<Space>" {
        desc = "Open :help prompt";
        nowait = true;
      })
      (mkKeymapWithOpts "n" "<leader>H" ":help <C-r><C-w><CR>" {desc = "Help for word under cursor";})
    ];
  };
}
