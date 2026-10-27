{
  targets = ["mango" "lettuce"];
  module = {
    # NOTE: avahi.settings isn't available on nixos-stable 26.05 yet,
    # move this back to network once nixos-raspberrypi image catches up (2026-10-24)
    services.avahi.settings.publish = {
      disable-publishing = false;
      publish-addresses = true;
    };
  };
}
