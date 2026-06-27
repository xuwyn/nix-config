{
  flake.modules.homeManager.dev = {pkgs, ...}: {
    home.packages = with pkgs; [
      # --- Dev Stuffs ---
      alejandra # Nix formatter
      nixfmt # Nix formatter
      pkg-config # Build dependency helper
      jq # json parser
    ];
  };
}
