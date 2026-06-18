{
  pkgs,
  host,
  ...
}: let
  inherit (import ../../../hosts/${host}/variables.nix) monitors;
  workspaceAssignments = builtins.concatLists (
    builtins.map (m:
      builtins.map (ws: {
        workspace = ws;
        output = m.name;
      })
      m.workspaces)
    monitors
  );
in {
  imports = [
    ./binds.nix
    ./windowcommands.nix
    ./startup.nix
  ];
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3;

    config = {
      bars = [];

      # Remove title bars for all windows
      window = {
        border = 1;
        titlebar = false;
      };

      floating = {
        border = 1;
        titlebar = false;
      };

      gaps = {
        inner = 6;
        outer = 10;
      };

      # Assign workspaces to specific monitor
      workspaceOutputAssign = workspaceAssignments;
    };

    extraConfig = ''
      default_border pixel 1
      for_window [class=".*"] border pixel 1
      title_align center
    '';
  };
}
