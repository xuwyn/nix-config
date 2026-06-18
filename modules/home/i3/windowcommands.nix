{...}: {
  xsession.windowManager.i3 = {
    config = {
      window.commands = [
        {
          command = "floating enable";
          criteria = {
            class = "^[Nn]m-connection-editor$";
          };
        }
        {
          command = "floating enable";
          criteria = {
            class = "^[pP]avucontrol$";
          };
        }
        {
          command = "floating enable";
          criteria = {window_role = "pop-up";};
        }
        {
          command = "floating enable";
          criteria = {window_role = "task_dialog";};
        }
        {
          command = "floating enable";
          criteria = {window_role = "Preferences";};
        }
        {
          command = "floating enable";
          criteria = {window_role = "About";};
        }
        {
          command = "floating enable";
          criteria = {window_type = "dialog";};
        }
        {
          command = "floating enable";
          criteria = {window_type = "menu";};
        }
      ];
    };
  };
}
