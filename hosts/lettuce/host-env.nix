{pkgs, ...}: {
  systemd.user.settings.Manager.DefaultEnvironment = {
    DISPLAY = ":0";
    WAYLAND_DISPLAY = "wayland-0";
    XDG_RUNTIME_DIR = "/run/user/1000";
  };
  home.sessionVariables = {
    DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/1000/bus";
    ZED_ALLOW_EMULATED_GPU = "1";
  };
}
