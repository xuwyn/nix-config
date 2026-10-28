{
  mgr.prepend_keymap = [
    {
      on = "!";
      run = ''shell "$SHELL" --block --confirm'';
      desc = "Open shell here";
    }
    {
      on = ["g" "r"];
      run = ''shell -- ya emit cd "$(git rev-parse --show-toplevel)"'';
      desc = "Cd to root of current git repo";
    }
    {
      on = "l";
      run = "plugin smart-enter";
      desc = "Enter the child directory, or open the file";
    }
    {
      on = "y";
      run = ["yank" "plugin yank-clipboard -- --action=copy"];
      desc = "Yank selected files";
    }
    {
      on = "x";
      run = ["yank --cut" "plugin yank-clipboard -- --action=copy"];
      desc = "Cut selected files";
    }
    {
      on = "<C-p>";
      run = "plugin yank-clipboard -- --action=paste";
      desc = "Paste files from system clipboard";
    }
    {
      on = "p";
      run = "plugin smart-paste";
      desc = "Paste into the hovered directory or CWD";
    }
    {
      on = ["g" "p"];
      run = "cd ~/Pictures";
      desc = "Go to Pictures";
    }
    {
      on = ["g" "l"];
      run = "cd ~/.local";
      desc = "Go to ~/.local";
    }
    {
      on = ["g" "v"];
      run = "cd ~/Videos";
      desc = "Go to Videos";
    }
  ];

  input.prepend_keymap = [
    {
      on = "<Esc>";
      run = "close";
      desc = "Cancel input";
    }
  ];
}
