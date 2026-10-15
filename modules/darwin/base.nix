{
  platforms = ["darwin"];
  module = {
    system.stateVersion = 6; # $ darwin-rebuild changelog
    time.timeZone = "America/Moncton";
  };
}
