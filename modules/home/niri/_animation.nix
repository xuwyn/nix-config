{
  wayland.windowManager.niri.settings.animations = {
    workspace-switch.spring._props = {
      damping-ratio = 1.0;
      stiffness = 1200;
      epsilon = 0.0001;
    };
    window-open = {
      duration-ms = 120;
      curve = "ease-out-expo";
    };
    window-close = {
      duration-ms = 100;
      curve = "ease-out-quad";
    };
    horizontal-view-movement.spring._props = {
      damping-ratio = 1.0;
      stiffness = 1000;
      epsilon = 0.0001;
    };
    window-movement.spring._props = {
      damping-ratio = 1.0;
      stiffness = 1000;
      epsilon = 0.0001;
    };
    window-resize.spring._props = {
      damping-ratio = 1.0;
      stiffness = 1000;
      epsilon = 0.0001;
    };
    overview-open-close.spring._props = {
      damping-ratio = 1.0;
      stiffness = 1000;
      epsilon = 0.0001;
    };
  };
}
