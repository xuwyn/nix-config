{
  services.dunst = {
    enable = true;

    settings = {
      global = {
        # Geometry & Alignment options
        width = 450;
        height = 200;
        origin = "top-right";
        offset = "15x15";
        scale = 0;
        notification_limit = 5;

        # font = "JetBrainsMono Nerd Font Mono 11"; # conflict with stylix
        line_height = 4;
        markup = "full";
        format = "<b>󰂚 %s</b>\n%b";

        # Pop-up
        frame_width = 2;
        corner_radius = 5;

        # Miscellaneous layout parameters
        progress_bar = true;
        progress_bar_height = 8;
        idle_threshold = 120;
        show_indicators = "yes";
        word_wrap = "yes";
      };

      # Custom styling triggers for severity urgency states
      urgency_low = {
        timeout = 3;
      };
      urgency_normal = {
        timeout = 5;
      };
      urgency_critical = {
        timeout = 0; # Stays stuck on screen until clicked away
      };
    };
  };
}
